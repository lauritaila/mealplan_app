import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';

class MealPlanEntriesMapper {
  static List<DayMealEntry> fromResponse(dynamic data) {
    final entries = _extractEntriesList(data);
    return entries
        .map((entry) => _mapEntry(Map<String, dynamic>.from(entry)))
        .toList();
  }

  static List<dynamic> _extractEntriesList(dynamic data) {
    if (data == null) return const [];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final entries = data['entries'] ?? data['meals'] ?? data['data'];
      if (entries is List) return entries;
    }
    return const [];
  }

  static DayMealEntry _mapEntry(Map<String, dynamic> entry) {
    final recipeMap = Map<String, dynamic>.from(entry['recipe'] ?? {});
    final ingredients = _mapIngredients(recipeMap);
    return DayMealEntry(
      mealType: _toMealType(entry['meal_type'] ?? entry['mealType']),
      name: (recipeMap['name'] ?? entry['name'] ?? '') as String,
      description:
          (recipeMap['description'] ?? entry['description'] ?? '') as String,
      instructions: (recipeMap['instructions'] ?? '') as String,
      ingredients: ingredients,
      servings: _toInt(
        entry['servings_planned'] ?? recipeMap['servings'] ?? entry['servings'],
      ),
      calories: _toDouble(recipeMap['calories'] ?? entry['calories']),
      fatsGrams: _toDouble(
        recipeMap['fats_grams'] ??
            recipeMap['fatsGrams'] ??
            entry['fats_grams'] ??
            entry['fatsGrams'],
      ),
      carbsGrams: _toDouble(
        recipeMap['carbs_grams'] ??
            recipeMap['carbsGrams'] ??
            entry['carbs_grams'] ??
            entry['carbsGrams'],
      ),
      proteinGrams: _toDouble(
        recipeMap['protein_grams'] ??
            recipeMap['proteinGrams'] ??
            entry['protein_grams'] ??
            entry['proteinGrams'],
      ),
    );
  }

  static String? _toMealType(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<DayMealIngredient> _mapIngredients(
    Map<String, dynamic> recipeMap,
  ) {
    final list =
        (recipeMap['ingredients'] ?? recipeMap['recipe_ingredients'])
            as List? ??
        const [];

    return list
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map((item) {
          final ingredientMap = Map<String, dynamic>.from(
            item['ingredient'] ?? item['ingredients'] ?? {},
          );
          final name = (ingredientMap['name'] ?? '') as String;
          if (name.isEmpty) return null;
          return DayMealIngredient(
            name: name,
            quantity: _toDouble(item['quantity']),
            unit: (item['unit'] ?? '') as String,
            category: (ingredientMap['category'] ?? '') as String,
          );
        })
        .whereType<DayMealIngredient>()
        .toList();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
