import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';

class CreateRecipeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ─── Form Key ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ─── Text Controllers ────────────────────────────────────────
  final mealNameCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();
  final thumbnailCtrl = TextEditingController();
  final youtubeCtrl = TextEditingController();

  // ─── State ───────────────────────────────────────────────────
  bool isLoading = false;
  List<String> availableCategories = [];
  String? selectedCategory;
  Uint8List? selectedImageBytes;
  String? selectedImagePath;
  List<Map<String, TextEditingController>> ingredients = [];

  CreateRecipeController() {
    addIngredient(); // เริ่มต้นด้วย 1 ช่อง
    _loadCategories();
  }

  // ─── Categories ──────────────────────────────────────────────
  Future<void> _loadCategories() async {
    final categories = await _apiService.fetchCategories();
    availableCategories = categories
        .map((c) => c['name'] as String)
        .where((name) => name.isNotEmpty)
        .toList();
    notifyListeners();
  }

  // ─── Image ───────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 50,
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

  // ─── Ingredients ─────────────────────────────────────────────
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

  // ─── Submit ───────────────────────────────────────────────────
  Future<bool> submitRecipe(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔑 TOKEN IN STORAGE: $token');
    print('IMAGE BYTES: $selectedImageBytes');
    print('IMAGE PATH: $selectedImagePath');

    if (!formKey.currentState!.validate()) return false;
    if (ingredients.isEmpty) return false;

    isLoading = true;
    notifyListeners();

    final idMeal = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final ingredientList = ingredients
        .where((ing) => ing['name']!.text.trim().isNotEmpty)
        .map((ing) => {
              'name': ing['name']!.text.trim(),
              'measure': ing['measure']!.text.trim(),
            })
        .toList();

    final recipeData = {
      'idMeal': idMeal,
      'strMeal': mealNameCtrl.text.trim(),
      'strCategory': selectedCategory ?? '',
      'strArea': areaCtrl.text.trim(),
      'strInstructions': instructionsCtrl.text.trim(),
      'strMealThumb': thumbnailCtrl.text.trim().isNotEmpty
          ? thumbnailCtrl.text.trim()
          : 'https://via.placeholder.com/300x200?text=No+Image',
      'strYoutube': youtubeCtrl.text.trim(),
      'strSource': '',
      'ingredients': ingredientList,
    };

    final success = await _apiService.createRecipe(
      recipeData,
      imageBytes: selectedImageBytes,
      imagePath: selectedImagePath,
    );

    isLoading = false;
    notifyListeners();

    return success;
  }

  // ─── Dispose ──────────────────────────────────────────────────
  @override
  void dispose() {
    mealNameCtrl.dispose();
    areaCtrl.dispose();
    instructionsCtrl.dispose();
    thumbnailCtrl.dispose();
    youtubeCtrl.dispose();
    for (var ing in ingredients) {
      ing['name']!.dispose();
      ing['measure']!.dispose();
    }
    super.dispose();
  }
}