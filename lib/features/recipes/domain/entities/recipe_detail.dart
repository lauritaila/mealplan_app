import 'package:meal_plan_app/features/recipes/domain/entities/recipe_ingredient.dart';

class RecipeDetail {
  final int id;
  final String name;
  final String instructions;
  final List<RecipeIngredient> ingredients;
  final bool isFavorite;
  final List<String> categories;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;

  const RecipeDetail({
    required this.id,
    required this.name,
    required this.instructions,
    required this.ingredients,
    required this.isFavorite,
    required this.categories,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
  });
}
