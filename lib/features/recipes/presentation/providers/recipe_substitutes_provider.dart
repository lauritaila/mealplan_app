import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_substitutes_provider.g.dart';

@riverpod
Future<List<IngredientSubstitute>> recipeSubstitutes(
  Ref ref,
  int recipeId,
  IngredientSubstitutesRequest request,
) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getIngredientSubstitutes(recipeId, request);
}
