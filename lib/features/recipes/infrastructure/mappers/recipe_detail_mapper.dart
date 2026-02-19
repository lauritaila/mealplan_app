import 'package:meal_plan_app/features/recipes/domain/entities/entities.dart';

class RecipeDetailMapper {
  static RecipeDetail fromMap(Map<String, dynamic> data) {
    final ingredientsRaw = (data['ingredients'] as List?) ?? const [];
    final ingredientsList = ingredientsRaw
        .map((ingredient) {
          final ingredientMap = Map<String, dynamic>.from(ingredient as Map);
          final nestedIngredient = ingredientMap['ingredient'];
          final nestedIngredientMap = nestedIngredient is Map
              ? Map<String, dynamic>.from(nestedIngredient)
              : const <String, dynamic>{};

          final name =
              _toStringOrNull(ingredientMap['name']) ??
              _toStringOrNull(nestedIngredientMap['name']) ??
              '';

          return RecipeIngredient(
            name: name,
            quantity: _toDouble(ingredientMap['quantity']),
            unit: _toStringOrNull(ingredientMap['unit']) ?? '',
          );
        })
        .where((ingredient) => ingredient.name.trim().isNotEmpty)
        .toList();

    return RecipeDetail(
      id: _parseRecipeId(data['id']),
      name: (data['name'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      instructions: (data['instructions'] ?? '') as String,
      ingredients: ingredientsList,
      isFavorite: (data['is_favorite'] ?? false) as bool,
      categories: List<String>.from(data['categories'] ?? []),
      calories: _toDouble(data['calories']),
      proteinGrams: _toDouble(data['protein_grams']),
      carbsGrams: _toDouble(data['carbs_grams']),
      fatsGrams: _toDouble(data['fats_grams']),
    );
  }

  static int _parseRecipeId(dynamic id) {
    if (id == null) {
      throw ArgumentError('RecipeDetail mapping error: id is null');
    }
    if (id is int) {
      return id;
    }
    if (id is String) {
      final parsed = int.tryParse(id);
      if (parsed != null) return parsed;
    }
    throw ArgumentError(
      'RecipeDetail mapping error: id is invalid type or value ($id)',
    );
  }

  static Map<String, dynamic> toMap(RecipeDetail entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'instructions': entity.instructions,
      'ingredients': entity.ingredients
          .map(
            (ingredient) => {
              'name': ingredient.name,
              'quantity': ingredient.quantity,
              'unit': ingredient.unit,
            },
          )
          .toList(),
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
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    if (parsed.isEmpty) return null;
    return parsed;
  }
}
