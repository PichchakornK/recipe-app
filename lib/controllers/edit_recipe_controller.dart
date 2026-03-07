import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';
import '../models/meal_model.dart';

class EditRecipeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final MealSummary meal;

  //  Form Key 
  final formKey = GlobalKey<FormState>();

  //  Text Controllers 
  final mealNameCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();
  final youtubeCtrl = TextEditingController();
  final thumbnailCtrl = TextEditingController();

  //  State 
  bool isLoading = false;
  bool isLoadingDetail = true;
  List<String> availableCategories = [];
  String? selectedCategory;
  Uint8List? selectedImageBytes;
  String? selectedImagePath;
  List<Map<String, TextEditingController>> ingredients = [];

  EditRecipeController({required this.meal}) {
    _loadDetail();
    _loadCategories();
  }

  //  Load Detail 
  Future<void> _loadDetail() async {
    final detail = await _apiService.fetchRecipeDetails(meal.id);
    if (detail == null) return;

    await Future.microtask(() {
      mealNameCtrl.text = detail.strMeal;
      areaCtrl.text = detail.strArea;
      instructionsCtrl.text = detail.strInstructions;
      youtubeCtrl.text = detail.strYoutube;
      thumbnailCtrl.text = detail.strMealThumb;
      selectedCategory = detail.strCategory;

      ingredients.clear();
      for (var ing in detail.ingredients) {
        ingredients.add({
          'name': TextEditingController(text: ing.name),
          'measure': TextEditingController(text: ing.measure),
        });
      }
      if (ingredients.isEmpty) {
        ingredients.add({
          'name': TextEditingController(),
          'measure': TextEditingController(),
        });
      }
      isLoadingDetail = false;
      notifyListeners();
    });
  }

  //  Load Categories 
  Future<void> _loadCategories() async {
    final categories = await _apiService.fetchCategories();
    availableCategories = categories
        .map((c) => c['name'] as String)
        .where((n) => n.isNotEmpty)
        .toList();
    notifyListeners();
  }

  //  Image 
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        selectedImageBytes = bytes;
      } else {
        selectedImagePath = picked.path;
      }
      notifyListeners();
    }
  }

  void selectCategory(String? val) {
    selectedCategory = val;
    notifyListeners();
  }

  //  Ingredients 
  void addIngredient() {
    ingredients.add({
      'name': TextEditingController(),
      'measure': TextEditingController(),
    });
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients[index]['name']!.dispose();
    ingredients[index]['measure']!.dispose();
    ingredients.removeAt(index);
    notifyListeners();
  }

  //  Submit 
  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;

    isLoading = true;
    notifyListeners();

    final ingredientList = ingredients
        .where((ing) => ing['name']!.text.trim().isNotEmpty)
        .map((ing) => {
              'name': ing['name']!.text.trim(),
              'measure': ing['measure']!.text.trim(),
            })
        .toList();

    final success = await _apiService.updateRecipe(meal.id, {
      'strMeal': mealNameCtrl.text.trim(),
      'strCategory': selectedCategory ?? '',
      'strArea': areaCtrl.text.trim(),
      'strInstructions': instructionsCtrl.text.trim(),
      'strYoutube': youtubeCtrl.text.trim(),
      'strMealThumb': thumbnailCtrl.text.trim(),
      'ingredients': ingredientList,
    });

    isLoading = false;
    notifyListeners();

    return success;
  }

  //  Dispose 
  @override
  void dispose() {
    mealNameCtrl.dispose();
    areaCtrl.dispose();
    instructionsCtrl.dispose();
    youtubeCtrl.dispose();
    thumbnailCtrl.dispose();
    for (var ing in ingredients) {
      ing['name']!.dispose();
      ing['measure']!.dispose();
    }
    super.dispose();
  }
}