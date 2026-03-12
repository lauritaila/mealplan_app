import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';


import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipesListScreen extends ConsumerWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesListProvider);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.recipesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: customColors.textDarkBlue),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: customColors.darkSage),
            onPressed: () => context.push('/recipes/favorites'),
            tooltip: l10n.favoritesTooltip,
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return AppEmptyState(
              title: l10n.noRecipesAvailable,
              subtitle: l10n.noDescriptionProvided, // Or a more suitable subtitle
              icon: Icons.restaurant_menu_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(recipesListProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  name: recipe.name,
                  isFavorite: recipe.isFavorite,
                  categories: recipe.categories,
                  calories: recipe.calories,
                  proteinGrams: recipe.proteinGrams,
                  carbsGrams: recipe.carbsGrams,
                  fatsGrams: recipe.fatsGrams,
                  hideNutritionValues: hideNutritionValues,
                  onTap: () => context.push('/recipes/${recipe.id}'),
                  onFavoriteTap: () async {
                    try {
                      await ref
                          .read(toggleFavoriteProvider.notifier)
                          .toggle(recipe.id);
                    } catch (e) {
                      if (!context.mounted) return;
                      CustomSnackbar.showInfo(context, l10n.favoriteUpdateFailed);
                    }
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
          onRetry: () => ref.invalidate(recipesListProvider),
        ),
      ),
    );
  }
}
