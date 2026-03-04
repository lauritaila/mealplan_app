import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'favorite_recipes_provider.g.dart';

@riverpod
class FavoriteRecipes extends _$FavoriteRecipes {
  @override
  Future<List<RecipeListItem>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    return repository.getFavoriteRecipes();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
