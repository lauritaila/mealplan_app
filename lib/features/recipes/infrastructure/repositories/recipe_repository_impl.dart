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

  @override
  Future<List<IngredientSubstitute>> getIngredientSubstitutes(
    int id,
    IngredientSubstitutesRequest request,
  ) {
    return _datasource.getIngredientSubstitutes(id, request);
  }

  @override
  Future<ApplyRecipeSubstituteResult> applySubstitute(
    int id,
    ApplyRecipeSubstituteRequest request,
  ) {
    return _datasource.applySubstitute(id, request);
  }

  @override
  Future<List<CookingAssistantStep>> getCookingAssistantSteps(int id) {
    return _datasource.getCookingAssistantSteps(id);
  }
}
