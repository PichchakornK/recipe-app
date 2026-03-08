import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart'; // เช็ก path นี้ให้ตรงกับโฟลเดอร์โปรเจกต์ของคุณด้วยนะครับ

class LoginController extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading; // ให้ UI ดึงค่าไปใช้ได้อย่างเดียว

  // ฟังก์ชันตั้งค่าสถานะโหลดและสั่งอัปเดต UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleLogin(BuildContext context) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showSnackBar(context, "กรุณากรอกอีเมลและรหัสผ่าน");
      return;
    }

    _setLoading(true);

    final String baseUrl = kIsWeb
        ? 'http://localhost:8080'
        : 'http://10.0.2.2:8080';
    final url = Uri.parse('$baseUrl/auth/login');
    print('kIsWeb: $kIsWeb');
    print('baseUrl: $baseUrl');
    print('url: $url');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      // เช็กว่าผู้ใช้ไม่ได้ปิดหน้าจอก่อนทำงานต่อ
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        //  ดึง Token
        final token = data['token'];

        // บันทึก Token ลง SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        debugPrint('token: $token');

        if (!context.mounted) return;

        // ไปหน้า HomePage และปิดหน้า Login ทิ้ง
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false, // ล้าง Stack ทั้งหมด รวมถึง StartPage ด้วย
        );
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(context, data['message'] ?? "เข้าสู่ระบบไม่สำเร็จ");
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้");
    } finally {
      _setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // คืนพื้นที่หน่วยความจำเมื่อไม่ได้ใช้งาน
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
