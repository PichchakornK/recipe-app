class MealSummary {
  final String id;
  final String name;
  final String thumbnail;
  final String category; 
  final String area;    

  MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.category,
    required this.area,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown',
      thumbnail: json['strMealThumb'] ?? '',
      category: json['strCategory'] ?? 'Unknown Category', 
      area: json['strArea'] ?? 'Unknown Area',             
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      measure: json['measure'] ?? '',
    );
  }
}

class RecipeDetail {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strMealThumb;
  final String strYoutube;
  final String strSource;
  final List<Ingredient> ingredients;

  RecipeDetail({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strMealThumb,
    required this.strYoutube,
    required this.strSource,
    required this.ingredients,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    var list = json['ingredients'] as List? ?? [];
    List<Ingredient> ingredientsList = list.map((i) => Ingredient.fromJson(i)).toList();

    return RecipeDetail(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      strSource: json['strSource'] ?? '',
      ingredients: ingredientsList,
    );
  }
}
