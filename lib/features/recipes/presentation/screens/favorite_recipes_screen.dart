import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/shared/widgets/select_list_sheet.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/toggle_favorite_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final showNutrition = authState is! AuthenticatedAuthState ||
        authState.user.configurations?['hideNutritionValues'] != true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.favoriteRecipesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: customColors.textDarkBlue),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return AppEmptyState(
              title: l10n.noFavoriteRecipes,
              icon: Icons.favorite_outline_rounded,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(favoriteRecipesProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return RecipeCard(
                  name: recipe.name,
                  isFavorite: recipe.isFavorite,
                  categories: recipe.categories,
                  calories: recipe.calories,
                  proteinGrams: recipe.proteinGrams,
                  carbsGrams: recipe.carbsGrams,
                  fatsGrams: recipe.fatsGrams,
                  hideNutritionValues: !showNutrition,
                  onTap: () => context.push('/recipes/${recipe.id}'),
                  onFavoriteTap: () async {
                    await ref
                        .read(toggleFavoriteProvider.notifier)
                        .toggle(recipe.id);
                  },
                  onAddToGroceryList: () async {
                    final selectedId = await showModalBottomSheet<int?>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SelectListSheet(
                        title: l10n.addRecipeToListTitle,
                        subtitle: l10n.organizeFavoritesSubtitle,
                      ),
                    );
                    if (selectedId == null || !context.mounted) return;
                    final ok = await ref
                        .read(groceryActionsProvider.notifier)
                        .importRecipe(selectedId, recipe.id);
                    if (!context.mounted) return;

                    String? listName;
                    final lists = ref.read(groceryListsProvider).asData?.value;
                    if (lists != null) {
                      listName = lists.firstWhere((l) => l.id == selectedId).name;
                    }

                    CustomSnackbar.showInfo(context, 
                          ok
                              ? l10n.recipeAddedToList(listName ?? l10n.groceryTitle)
                              : l10n.recipeAddFailed,
                        );
                  },
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: customColors.darkSage,
          ),
        ),
        error: (error, stack) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoriteRecipesProvider),
        ),
      ),
    );
  }
}
