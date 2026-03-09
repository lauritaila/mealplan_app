import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/utils/ingredient_substitute_flow.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeDetailTitle),
        actions: [
          recipeAsync.maybeWhen(
            data: (recipe) => IconButton(
              icon: Icon(
                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: recipe.isFavorite ? Colors.red : null,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(toggleFavoriteProvider.notifier)
                      .toggle(recipeId);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.favoriteUpdateFailed)),
                  );
                  // Optionally revert optimistic UI changes here if needed
                }
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: recipeAsync.when(
        data: (recipe) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Name
                Text(
                  recipe.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Categories
                if (recipe.categories.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: recipe.categories.map((category) {
                      return Chip(
                        label: Text(category),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (!hideNutritionValues) ...[
                  Text(
                    l10n.nutritionTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  NutritionSummaryCard(
                    protein: recipe.proteinGrams,
                    fats: recipe.fatsGrams,
                    carbs: recipe.carbsGrams,
                    calories: recipe.calories,
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  l10n.descriptionTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description.trim().isEmpty ? '-' : recipe.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Ingredients Section
                Text(
                  l10n.ingredientsTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (recipe.ingredients.isEmpty)
                  Text(l10n.noIngredients, style: theme.textTheme.bodyLarge)
                else
                  ...recipe.ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatIngredientLine(
                                quantity: ingredient.quantity,
                                unit: ingredient.unit,
                                name: ingredient.name,
                              ),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: l10n.ingredientSubstitutesTooltip,
                            onPressed: () {
                              showIngredientSubstituteFlow(
                                context: context,
                                ref: ref,
                                recipeId: recipeId,
                                ingredient: ingredient,
                                hideNutritionValues: hideNutritionValues,
                                contextHint: recipe.name,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: () {
                    context.push('/recipes/$recipeId/assistant');
                  },
                  icon: const Icon(Icons.play_circle_fill),
                  label: Text(l10n.openCookingAssistant),
                ),
                const SizedBox(height: 24),

                // Instructions Section
                Text(
                  l10n.instructionsTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.instructions.trim().isEmpty
                      ? l10n.noInstructions
                      : recipe.instructions,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
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
                onPressed: () => ref.invalidate(recipeDetailProvider(recipeId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatIngredientLine({
    required double? quantity,
    required String unit,
    required String name,
  }) {
    final safeName = name.trim();
    final safeUnit = unit.trim();

    String quantityText = '';
    if (quantity != null) {
      quantityText = quantity == quantity.roundToDouble()
          ? quantity.toInt().toString()
          : quantity
                .toStringAsFixed(2)
                .replaceFirst(RegExp(r'0+$'), '')
                .replaceFirst(RegExp(r'\.$'), '');
    }

    return [
      quantityText,
      safeUnit,
      safeName,
    ].where((part) => part.isNotEmpty).join(' ');
  }
}
