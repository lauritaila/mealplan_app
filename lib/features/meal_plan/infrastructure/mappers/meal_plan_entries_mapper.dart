import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';

class MealPlanEntriesMapper {
  static List<DayMealEntry> fromResponse(dynamic data) {
    final entries = _extractEntriesList(data);
    return entries
        .map((entry) => _mapEntry(Map<String, dynamic>.from(entry)))
        .toList();
  }

  static DayMealEntry fromEntryMap(Map<String, dynamic> data) {
    return _mapEntry(data);
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
    final categories = _mapCategories(recipeMap['categories']);
    return DayMealEntry(
      entryId: _toInt(entry['id']) ?? 0,
      recipeId: _toInt(recipeMap['id'] ?? entry['recipe_id']) ?? 0,
      mealType: _toMealType(entry['meal_type'] ?? entry['mealType']),
      name: (recipeMap['name'] ?? entry['name'] ?? '') as String,
      status: _toStatus(entry['status']),
      categories: categories,
      description: _toNullableString(
        recipeMap['description'] ?? entry['description'],
      ),
      instructions: _toNullableString(recipeMap['instructions']),
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
      mealDate: _toDateTime(entry['meal_date'] ?? entry['mealDate']),
    );
  }

  static String? _toStatus(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return null;
    if (text == 'skiped') return 'skipped';
    return text;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.trim().isEmpty ? null : text;
  }

  static List<String> _mapCategories(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.tryParse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
