import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipes_list_provider.g.dart';

@riverpod
class RecipesList extends _$RecipesList {
  @override
  Future<List<RecipeListItem>> build() async {
    final repository = ref.watch(recipeRepositoryProvider);
    return repository.getUserRecipes();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
