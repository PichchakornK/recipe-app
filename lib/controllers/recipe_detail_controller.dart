import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class RecipeDetailController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  RecipeDetail? recipe;
  bool isLoading = true;
  String? errorMessage;

  // ฟังก์ชันโหลดข้อมูลสูตรอาหาร
  Future<void> loadRecipe(String idMeal) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedRecipe = await _apiService.fetchRecipeDetails(idMeal);
      if (fetchedRecipe != null) {
        recipe = fetchedRecipe;
      } else {
        errorMessage = "ไม่พบข้อมูลสูตรอาหาร";
      }
    } catch (e) {
      errorMessage = "เกิดข้อผิดพลาดในการโหลดข้อมูล";
      debugPrint("Error loading recipe details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
