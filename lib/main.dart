import 'package:flutter/material.dart';
import 'pages/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // ดึงค่าที่บันทึกจากหน้า Login
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(useMaterial3: true),
      // ใช้ FutureBuilder เพื่อเช็กสถานะก่อนแสดงหน้าแรก
      home: FutureBuilder<bool>(
        future: isUserLoggedIn(),
        builder: (context, snapshot) {
          // 1. ระหว่างที่กำลังอ่านข้อมูลจากเครื่อง (ยังไม่มีผลลัพธ์)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
              ),
            );
          }

          // 2. ถ้าอ่านข้อมูลเสร็จแล้ว และผลลัพธ์เป็น true (มี Token)
          if (snapshot.data == true) {
            return const HomePage(); //
          }

          // 3. ถ้าไม่มีข้อมูล หรือไม่ได้ล็อกอิน ให้ไปหน้าเริ่มต้น
          return const StartPage(); //
        },
      ),
    );
  }
}
