import 'package:meal_plan_app/features/recipes/presentation/providers/favorite_recipes_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_detail_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipes_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_favorite_provider.g.dart';

enum ToggleFavoriteStatus { initial, loading, success, error }

class ToggleFavoriteState {
  final ToggleFavoriteStatus status;
  final String? errorMessage;
  final bool? isFavorite;

  ToggleFavoriteState({
    this.status = ToggleFavoriteStatus.initial,
    this.errorMessage,
    this.isFavorite,
  });

  ToggleFavoriteState copyWith({
    ToggleFavoriteStatus? status,
    String? errorMessage,
    bool? isFavorite,
    bool clearError = false,
  }) {
    return ToggleFavoriteState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@riverpod
class ToggleFavorite extends _$ToggleFavorite {
  @override
  ToggleFavoriteState build() {
    return ToggleFavoriteState();
  }

  Future<void> toggle(int recipeId) async {
    state = state.copyWith(
      status: ToggleFavoriteStatus.loading,
      clearError: true,
    );

    try {
      final repository = ref.read(recipeRepositoryProvider);
      final isFavorite = await repository.toggleFavorite(recipeId);

      state = state.copyWith(
        status: ToggleFavoriteStatus.success,
        isFavorite: isFavorite,
        clearError: true,
      );

      // Invalidate lists to refresh the UI
      ref.invalidate(recipesListProvider);
      ref.invalidate(favoriteRecipesProvider);
      ref.invalidate(recipeDetailProvider(recipeId));
    } catch (e) {
      state = state.copyWith(
        status: ToggleFavoriteStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = ToggleFavoriteState();
  }
}
