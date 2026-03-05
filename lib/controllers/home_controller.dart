import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/api_service.dart';

class HomeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ตัวแปรเก็บข้อมูลหมวดหมู่
  String selectedCategory = '';
  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  // ตัวแปรเก็บข้อมูลอาหารที่ค้นหา/เลือก
  List<MealSummary> meals = [];
  bool isLoadingMeals = true;

  // ตัวแปรเก็บสถานะการเซฟ
  Set<String> savedMealIds = {};

  // ตัวแปรค้นหา
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // โหลดข้อมูลเริ่มต้น
  Future<void> initLoad() async {
    await loadCategories();
    await loadSavedStatus();
  }

  Future<void> loadCategories() async {
    isLoadingCategories = true;
    notifyListeners();

    try {
      final fetchedCategories = await _apiService.fetchCategories();
      if (fetchedCategories.isNotEmpty) {
        categories = fetchedCategories;
        selectedCategory = fetchedCategories[0]['name'];
      }
    } finally {
      isLoadingCategories = false;
      notifyListeners();
      fetchMeals(); // โหลดอาหารของหมวดหมู่แรกต่อทันที
    }
  }

  Future<void> loadSavedStatus() async {
    final savedMeals = await _apiService.fetchSavedRecipes();
    savedMealIds = savedMeals.map((m) => m.id).toSet();
    notifyListeners();
  }

  Future<void> fetchMeals() async {
    isLoadingMeals = true;
    notifyListeners();

    try {
      if (searchQuery.isNotEmpty) {
        meals = await _apiService.searchRecipes(searchQuery);
      } else if (selectedCategory.isNotEmpty) {
        meals = await _apiService.fetchMealsByCategory(selectedCategory);
      }
    } finally {
      isLoadingMeals = false;
      notifyListeners();
    }
  }

  // เมื่อเลือกหมวดหมู่ใหม่
  void selectCategory(String category) {
    if (selectedCategory != category) {
      selectedCategory = category;
      searchQuery = ''; // ล้างคำค้นหาเมื่อเปลี่ยนหมวดหมู่
      searchController.clear();
      fetchMeals();
    }
  }

  // เมื่อพิมพ์ค้นหา
  void search(String query) {
    searchQuery = query;
    fetchMeals();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery = '';
    fetchMeals();
  }

  // เมื่อกดปุ่มหัวใจ
  Future<void> toggleSave(String mealId) async {
    final isSaved = savedMealIds.contains(mealId);
    if (isSaved) {
      final success = await _apiService.unsaveRecipe(mealId);
      if (success) {
        savedMealIds.remove(mealId);
        notifyListeners();
      }
    } else {
      final success = await _apiService.saveRecipe(mealId);
      if (success) {
        savedMealIds.add(mealId);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}