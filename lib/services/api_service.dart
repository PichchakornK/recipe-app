import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';
import 'dart:typed_data';

class ApiService {
  // ตั้งค่า URL ให้ชี้ไปที่ Backend
  String get baseUrl {
    return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/recipe/get');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        List<dynamic> mealsJson = [];

        // ตรวจสอบรูปแบบ JSON ที่ Backend ส่งมา
        // (เผื่อ Backend ส่งมาเป็น Array ตรงๆ หรือหุ้มไว้ใน Object เช่น { "recipes": [...] })
        if (data is List) {
          mealsJson = data;
        } else if (data['recipes'] != null) {
          mealsJson = data['recipes'];
        } else if (data['data'] != null) {
          mealsJson = data['data'];
        }

        // กรองข้อมูลตาม Category (ถ้า Backend ดึงมาทั้งหมด)
        // ถ้า Backend ไม่ได้กรอง Category มาให้ เราก็มากรองที่ Flutter ได้เลยครับ
        final filteredMeals = mealsJson.where((meal) {
          // เช็คว่าเมนูนี้มี category ตรงกับที่เลือกในหน้า Home หรือไม่
          // toLowerCase() ทั้งสองฝั่ง ป้องกัน case ไม่ตรง
          return (meal['strCategory'] as String? ?? '').toLowerCase() ==
              category.toLowerCase();
        }).toList();

        // แปลงเป็น Object MealSummary ส่งกลับไปหน้า Home
        return filteredMeals.map((json) => MealSummary.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load meals from Backend');
      }
    } catch (e) {
      debugPrint('Error Fetching from Backend: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/recipe/categories');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        // รับข้อมูลเป็นรูปแบบ Map (Object) แทน String ธรรมดา
        if (data['categories'] != null) {
          return List<Map<String, dynamic>>.from(data['categories']);
        }
        return [];
      } else {
        debugPrint('Backend Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Connection Error: $e');
      return [];
    }
  }

  Future<RecipeDetail?> fetchRecipeDetails(String idMeal) async {
    final url = Uri.parse('$baseUrl/recipe/search/$idMeal');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return RecipeDetail.fromJson(data);
      } else {
        debugPrint('Backend Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Connection Error: $e');
      return null;
    }
  }

  // ดึง Token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  //  เซฟเมนู (ยิงส่ง idMeal)
  Future<bool> saveRecipe(String idMeal) async {
    final url = Uri.parse('$baseUrl/recipe/saved-recipe');
    final token = await _getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "idMeal": idMeal,
        }), // ส่ง idMeal ไปตามที่ Backend รอรับ
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ยกเลิกการเซฟ
  Future<bool> unsaveRecipe(String idMeal) async {
    final url = Uri.parse('$baseUrl/recipe/saved-recipe/$idMeal');
    final token = await _getToken();

    try {
      final response = await http.delete(
        url,
        headers: {if (token != null) "Authorization": "Bearer $token"},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ดึงรายการที่เคยเซฟไว้ทั้งหมด
  Future<List<MealSummary>> fetchSavedRecipes() async {
    final url = Uri.parse('$baseUrl/recipe/saved-recipe');
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {if (token != null) "Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MealSummary.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ค้นหาเมนูอาหาร (GET /recipe/get?q=คำค้นหา)
  Future<List<MealSummary>> searchRecipes(String query) async {
    final url = Uri.parse('$baseUrl/recipe/get?q=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> mealsJson = [];

        if (data is List) {
          mealsJson = data;
        } else if (data['recipes'] != null) {
          mealsJson = data['recipes'];
        } else if (data['data'] != null) {
          mealsJson = data['data'];
        }

        return mealsJson.map((json) => MealSummary.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error Searching Recipes: $e');
      return [];
    }
  }

  Future<bool> createRecipe(
    Map<String, dynamic> recipeData, {
    Uint8List? imageBytes,
    String? imagePath,
  }) async {
    final url = Uri.parse('$baseUrl/recipe/create');
    final token = await _getToken();
    if (token == null) return false;

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['data'] = jsonEncode([recipeData]);

      if (kIsWeb && imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'upload.jpg',
          ),
        );
      } else if (!kIsWeb && imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      // เพิ่ม timeout
      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final statusCode = response.statusCode;
      print('CREATE RECIPE STATUS: $statusCode'); // เพิ่ม
      return statusCode == 201;
    } catch (e) {
      print('Create Recipe Error: $e'); // ดู error จริงๆ
      return false;
    }
  }

  // ดึง recipe ที่ฉันสร้าง
  Future<List<MealSummary>> fetchMyRecipes() async {
    final url = Uri.parse('$baseUrl/recipe/my-recipe');
    final token = await _getToken();
    //print('FETCH MY RECIPES TOKEN: $token');
    try {
      final response = await http.get(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MealSummary.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // แก้ไข recipe
  Future<bool> updateRecipe(String idMeal, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/recipe/update/$idMeal');
    final token = await _getToken();
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ลบ recipe
  Future<bool> deleteRecipe(String idMeal) async {
    final url = Uri.parse('$baseUrl/recipe/delete/$idMeal');
    final token = await _getToken();
    try {
      final response = await http.delete(
        url,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
