import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/infrastructure/infrastructure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_repository_provider.g.dart';

@riverpod
RecipeRepository recipeRepository(Ref ref) {
  final datasource = SupabaseRecipeDatasource();
  return RecipeRepositoryImpl(datasource);
}
