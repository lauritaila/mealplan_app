import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoriteRecipesTitle)),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    l10n.noFavoriteRecipes,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
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
                  hideNutritionValues: hideNutritionValues,
                  onTap: () => context.push('/recipes/${recipe.id}'),
                  onFavoriteTap: () async {
                    await ref
                        .read(toggleFavoriteProvider.notifier)
                        .toggle(recipe.id);
                  },
                  onAddToGroceryList: () async {
                    final selected = await showSelectOrCreateGroceryListSheet(
                      context: context,
                      ref: ref,
                      title: 'Agregar receta a lista',
                    );
                    if (selected == null || !context.mounted) return;
                    final ok = await ref
                        .read(groceryActionsProvider.notifier)
                        .importRecipe(selected.id, recipe.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Receta agregada a "${selected.name}"'
                              : 'No se pudo agregar la receta',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred(error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(favoriteRecipesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
