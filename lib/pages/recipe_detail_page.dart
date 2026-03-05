import 'package:flutter/material.dart';
// อย่าลืม import ไฟล์ Controller ที่เพิ่งสร้างใหม่
import '../controllers/recipe_detail_controller.dart';

class RecipeDetailPage extends StatefulWidget {
  final String idMeal;

  const RecipeDetailPage({super.key, required this.idMeal});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  // สร้างตัวแปร Controller แทน ApiService เดิม
  late final RecipeDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RecipeDetailController();
    // สั่งให้โหลดข้อมูลทันทีที่เปิดหน้านี้
    _controller.loadRecipe(widget.idMeal);
  }

  @override
  void dispose() {
    // ล้างข้อมูลเพื่อคืนหน่วยความจำ
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ใช้ ListenableBuilder แทน FutureBuilder
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {

          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            );
          }

          if (_controller.errorMessage != null || _controller.recipe == null) {
            return Center(
              child: Text(_controller.errorMessage ?? "ไม่พบข้อมูลสูตรอาหาร"),
            );
          }

          final recipe = _controller.recipe!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,

                pinned: true,

                backgroundColor: Colors.white,

                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),

                  onPressed: () => Navigator.pop(context),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    recipe.strMealThumb,

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ส่วนรายละเอียดด้านล่าง
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ชื่อเมนู
                      Text(
                        recipe.strMeal,

                        style: const TextStyle(
                          fontSize: 26,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // หมวดหมู่และสัญชาติ
                      Row(
                        children: [
                          _buildChip(recipe.strCategory, Icons.restaurant_menu),

                          const SizedBox(width: 10),

                          _buildChip(recipe.strArea, Icons.location_on),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ส่วนประกอบ (Ingredients)
                      const Text(
                        "Ingredients",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ...recipe.ingredients.map(
                        (ingredient) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFFF6B35),
                                size: 20,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  ingredient.name,

                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),

                              Text(
                                ingredient.measure,

                                style: const TextStyle(
                                  fontSize: 16,

                                  fontWeight: FontWeight.bold,

                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // วิธีทำ (Instructions)
                      const Text(
                        "Instructions",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        recipe.strInstructions,

                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 👇 นำฟังก์ชัน _buildChip ของเก่ามาวางไว้ข้างล่างตรงนี้ได้เลย
  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
