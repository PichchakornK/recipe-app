import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class SavedRecipesController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MealSummary> savedMeals = [];
  bool isLoading = true;

  // ฟังก์ชันโหลดข้อมูลเมนูที่เซฟไว้
  Future<void> loadSavedRecipes() async {
    isLoading = true;
    notifyListeners(); // สั่งให้ UI โชว์ตัวหมุน (Loading)

    try {
      final meals = await _apiService.fetchSavedRecipes();
      savedMeals = meals;
    } catch (e) {
      debugPrint("Error loading saved recipes: $e");
      savedMeals = [];
    } finally {
      isLoading = false;
      notifyListeners(); // สั่งให้ UI อัปเดตหลังจากได้ข้อมูล
    }
  }

  // ฟังก์ชันยกเลิกการเซฟ
  Future<void> unsaveRecipe(String idMeal) async {
    final success = await _apiService.unsaveRecipe(idMeal);
    if (success) {
      // เอาออกจากลิสต์แล้วอัปเดตหน้าจอทันทีโดยไม่ต้องโหลด API ใหม่
      savedMeals.removeWhere((meal) => meal.id == idMeal);
      notifyListeners();
    }
  }
}
