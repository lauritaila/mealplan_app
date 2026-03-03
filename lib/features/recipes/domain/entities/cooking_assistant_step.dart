import 'package:meal_plan_app/features/recipes/domain/entities/recipe_ingredient.dart';

class CookingAssistantStep {
  final int stepNumber;
  final String instruction;
  final List<RecipeIngredient> ingredientsUsed;
  final List<String> toolsNeeded;
  final int estimatedTimeSeconds;

  const CookingAssistantStep({
    required this.stepNumber,
    required this.instruction,
    required this.ingredientsUsed,
    required this.toolsNeeded,
    required this.estimatedTimeSeconds,
  });
}
