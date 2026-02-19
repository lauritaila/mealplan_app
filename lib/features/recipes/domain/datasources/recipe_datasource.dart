import 'package:meal_plan_app/features/recipes/domain/entities/entities.dart';

abstract class RecipeDatasource {
  Future<List<RecipeListItem>> getUserRecipes();
  Future<List<RecipeListItem>> getFavoriteRecipes();
  Future<RecipeDetail> getRecipeDetail(int id);
  Future<bool> toggleFavorite(int id);
}
