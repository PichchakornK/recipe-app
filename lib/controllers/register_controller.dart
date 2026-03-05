import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class RegisterController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading; // ให้ UI ดึงค่าไปใช้ได้เท่านั้น ป้องกันการแก้ค่าโดยตรง

  // ฟังก์ชันสำหรับจัดการการโหลดและแจ้งให้ UI อัปเดต
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleRegister(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar(context, "กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar(context, "รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน");
      return;
    }

    _setLoading(true);

    final String baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
    final url = Uri.parse('$baseUrl/auth/create');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
        }),
      );

      // ตรวจสอบว่าหน้าจอยังเปิดอยู่หรือไม่ก่อนทำงานต่อ
      if (!context.mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar(context, "สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ");

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(context, data['message'] ?? "เกิดข้อผิดพลาด");
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้");
      print("Error: $e");
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

  // เพิ่ม dispose เพื่อป้องกัน Memory Leak (การกินแรมค้าง)
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}