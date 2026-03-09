import 'package:meal_plan_app/features/recipes/domain/entities/entities.dart';

class RecipeListItemMapper {
  static RecipeListItem fromMap(Map<String, dynamic> data) {
    return RecipeListItem(
      id: data['id'] as int,
      name: (data['name'] ?? '') as String,
      isFavorite: (data['is_favorite'] ?? false) as bool,
      categories: List<String>.from(data['categories'] ?? []),
      calories: _toDouble(data['calories']),
      proteinGrams: _toDouble(data['protein_grams']),
      carbsGrams: _toDouble(data['carbs_grams']),
      fatsGrams: _toDouble(data['fats_grams']),
    );
  }

  static Map<String, dynamic> toMap(RecipeListItem entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'is_favorite': entity.isFavorite,
      'categories': entity.categories,
      'calories': entity.calories,
      'protein_grams': entity.proteinGrams,
      'carbs_grams': entity.carbsGrams,
      'fats_grams': entity.fatsGrams,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
