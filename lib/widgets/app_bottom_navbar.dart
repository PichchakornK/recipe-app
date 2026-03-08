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
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SavedRecipesPage()),
            (route) => route.settings.name == '/home' || route.isFirst,
          );
        } else if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
            (route) => route.isFirst,
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
