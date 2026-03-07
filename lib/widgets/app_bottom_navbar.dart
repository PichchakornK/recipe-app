import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/saved_recipes_page.dart';
import '../pages/profile_page.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: const Color(0xFFFF6B35),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (int index) {
        // ถ้ากดที่เมนูเดิม ไม่ต้องทำอะไร
        if (index == currentIndex) return;

        if (index == 0) {
          // ใช้ pushReplacement เพื่อไม่ให้ Stack หน้าจอซ้อนกันจนย้อนกลับลำบาก
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SavedRecipesPage()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
      ],
    );
  }
}
