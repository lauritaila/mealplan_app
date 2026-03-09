import 'package:meal_plan_app/features/recipes/domain/entities/recipe_ingredient.dart';

class RecipeDetail {
  final int id;
  final String name;
  final String instructions;
  final String description;
  final List<RecipeIngredient> ingredients;
  final bool isFavorite;
  final List<String> categories;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final int? baseServings;

  const RecipeDetail({
    required this.id,
    required this.name,
    required this.instructions,
    required this.description,
    required this.ingredients,
    required this.isFavorite,
    required this.categories,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
    this.baseServings,
  });
}
