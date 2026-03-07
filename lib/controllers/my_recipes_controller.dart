import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal_model.dart';

class MyRecipesController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State 
  List<MealSummary> myRecipes = [];
  bool isLoading = true;

  MyRecipesController() {
    loadMyRecipes();
  }

  //  Load 
  Future<void> loadMyRecipes() async {
    isLoading = true;
    notifyListeners();

    final recipes = await _apiService.fetchMyRecipes();
    print('MY RECIPES COUNT: ${recipes.length}');
    for (var r in recipes) {
      print('RECIPE: ${r.name} - ${r.id}');
    }

    myRecipes = recipes;
    isLoading = false;
    notifyListeners();
  }

  //  Delete 
  Future<bool> deleteRecipe(String idMeal) async {
    final success = await _apiService.deleteRecipe(idMeal);
    if (success) {
      myRecipes.removeWhere((r) => r.id == idMeal);
      notifyListeners();
    }
    return success;
  }
}