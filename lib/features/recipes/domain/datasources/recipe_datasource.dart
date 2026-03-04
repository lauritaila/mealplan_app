import 'package:meal_plan_app/features/recipes/domain/entities/entities.dart';

abstract class RecipeDatasource {
  Future<List<RecipeListItem>> getUserRecipes();
  Future<List<RecipeListItem>> getFavoriteRecipes();
  Future<RecipeDetail> getRecipeDetail(int id);
  Future<bool> toggleFavorite(int id);
  Future<List<IngredientSubstitute>> getIngredientSubstitutes(
    int id,
    IngredientSubstitutesRequest request,
  );
  Future<ApplyRecipeSubstituteResult> applySubstitute(
    int id,
    ApplyRecipeSubstituteRequest request,
  );
  Future<List<CookingAssistantStep>> getCookingAssistantSteps(int id);
}
