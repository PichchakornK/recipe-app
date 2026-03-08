import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/start_page.dart';

class UserController extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _createdAt = "";
  String _userId = "";

  String? _profileImage;
  File? _imageFile;

  bool _isLoading = false;

  String get name => _name;
  String get email => _email;
  String get createdAt => _createdAt;
  String? get profileImage => _profileImage;
  File? get imageFile => _imageFile;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }

  Map<String, dynamic> _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      String payload = parts[1];
      payload += List.filled((4 - payload.length % 4) % 4, '=').join();
      final decodedBytes = base64Url.decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      return jsonDecode(decodedString);
    } catch (e) {
      return {};
    }
  }

  // โหลดข้อมูลเริ่มต้นและเรียก API
  Future<void> loadUserData() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        // 1. ถอด Token เพื่อเอาแค่ userId และ email
        final data = _parseJwt(token);
        _userId = data['userId'].toString();
        _email = data['email'] ?? "";

        // 2. ไปดึงข้อมูลสดๆ จาก Backend
        await fetchUserFromApi();
      }
    } finally {
      _setLoading(false);
    }
  }

  // ฟังก์ชันดึงข้อมูลจาก Database สดๆ
  Future<void> fetchUserFromApi() async {
    final String baseUrl = kIsWeb
        ? 'http://localhost:8080'
        : 'http://10.0.2.2:8080';
    final url = Uri.parse('$baseUrl/auth/users'); // Endpoint getUser ของคุณ

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);

        // ค้นหา User ตัวเองจาก Array ที่ Backend ส่งมา
        final myUser = users.firstWhere(
          (u) => u['id'].toString() == _userId,
          orElse: () => null,
        );

        if (myUser != null) {
          _name = myUser['name'] ?? "ยังไม่ได้ตั้งชื่อ";
          _createdAt = myUser['createAt'] != null
              ? DateTime.parse(
                  myUser['createAt'],
                ).toLocal().toString().split(' ')[0]
              : "ไม่ทราบข้อมูล";
          _profileImage = myUser['profileImage']; // รูปจาก Cloudinary
          notifyListeners(); // สั่งให้อัปเดต UI ทันที
        }
      }
    } catch (e) {
      debugPrint("Fetch User Error: $e");
    }
  }

  Future<bool> updateProfile(BuildContext context, String newName) async {
    _setLoading(true);
    final String baseUrl = kIsWeb
        ? 'http://localhost:8080'
        : 'http://10.0.2.2:8080';
    final url = Uri.parse('$baseUrl/auth/update-profile');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';

      // เช็คว่าถ้ามีชื่อใหม่ถึงจะส่งไป
      if (newName.isNotEmpty) {
        request.fields['name'] = newName;
      }

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _imageFile = null; // ล้างรูปที่ค้างในเครื่อง
        await fetchUserFromApi(); // ✅ ดึงข้อมูลใหม่จาก DB ทันที
        if (context.mounted)
          _showSnackBar(context, "อัปเดตโปรไฟล์สำเร็จ", isError: false);
        return true;
      } else {
        if (context.mounted)
          _showSnackBar(context, "อัปเดตไม่สำเร็จ: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      if (context.mounted)
        _showSnackBar(context, "เกิดข้อผิดพลาดในการเชื่อมต่อ");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    // โค้ด Logout ของคุณเหมือนเดิม
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!context.mounted) return;
    _name = "";
    _email = "";
    _createdAt = "";
    _profileImage = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartPage()),
      (route) => false,
    );
    _setLoading(false);
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
