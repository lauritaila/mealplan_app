import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class RecipesListScreen extends ConsumerWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesListProvider);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push('/recipes/favorites'),
            tooltip: l10n.favoritesTooltip,
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(child: Text(l10n.noRecipesAvailable));
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update favorite. Please try again.',
                          ),
                        ),
                      );
                      // Optionally revert optimistic UI changes here if needed
                    }
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
                onPressed: () => ref.invalidate(recipesListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
