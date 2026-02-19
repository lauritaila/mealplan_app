import 'package:meal_plan_app/features/recipes/domain/domain.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeDatasource _datasource;

  RecipeRepositoryImpl(this._datasource);

  @override
  Future<List<RecipeListItem>> getUserRecipes() {
    return _datasource.getUserRecipes();
  }

  @override
  Future<List<RecipeListItem>> getFavoriteRecipes() {
    return _datasource.getFavoriteRecipes();
  }

  @override
  Future<RecipeDetail> getRecipeDetail(int id) {
    return _datasource.getRecipeDetail(id);
  }

  @override
  Future<bool> toggleFavorite(int id) {
    return _datasource.toggleFavorite(id);
  }
}
