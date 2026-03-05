import 'package:flutter/material.dart';
import '../controllers/saved_recipes_controller.dart'; 
import 'recipe_detail_page.dart';

class SavedRecipesPage extends StatefulWidget {
  const SavedRecipesPage({super.key});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  // สร้างตัวแปร Controller
  late final SavedRecipesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SavedRecipesController();
    _controller.loadSavedRecipes(); // สั่งให้โหลดข้อมูลทันทีที่เปิดหน้านี้
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Saved Recipes', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // ใช้ ListenableBuilder ครอบไว้เพื่อให้ UI อัปเดตตาม Controller
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          
          // 1. ถ้ากำลังโหลดข้อมูล
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            );
          }

          // 2. ถ้าไม่มีข้อมูล
          if (_controller.savedMeals.isEmpty) {
            return const Center(child: Text('ไม่มีเมนูที่บันทึกไว้'));
          }

          // 3. ถ้ามีข้อมูล ให้แสดงผลเป็น ListView
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.savedMeals.length,
            itemBuilder: (context, index) {
              final meal = _controller.savedMeals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      meal.thumbnail,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    meal.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${meal.category}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      // สั่งงานผ่าน Controller ให้อัปเดตข้อมูลให้
                      await _controller.unsaveRecipe(meal.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(idMeal: meal.id),
                      ),
                    ).then((_) {
                      // เมื่อกลับมาจากหน้า Detail โหลดข้อมูลใหม่ (เผื่อเขากดยกเลิกเซฟในหน้า Detail)
                      _controller.loadSavedRecipes();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}