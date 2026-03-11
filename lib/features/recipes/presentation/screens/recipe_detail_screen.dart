import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/utils/ingredient_substitute_flow.dart';
import 'package:meal_plan_app/features/shared/widgets/select_list_sheet.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final int recipeId;
  final int? entryId;
  final String? status;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.entryId,
    this.status,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  String? _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeDetailProvider(widget.recipeId));
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    // Check if the recipe is already completed
    final isCompleted = _currentStatus?.toLowerCase() == 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.recipeDetailTitle,
          style: const TextStyle(color: Color(0xFF1A1E1B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1E1B)),
        actions: [
          recipeAsync.maybeWhen(
            data: (recipe) => IconButton(
              icon: Icon(
                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: recipe.isFavorite ? Colors.red : const Color(0xFF1A1E1B),
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(toggleFavoriteProvider.notifier)
                      .toggle(widget.recipeId);
                } catch (e) {
                  if (!context.mounted) return;
                  CustomSnackbar.showInfo(context, l10n.favoriteUpdateFailed);
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Name
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1E1B),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                // Categories
                if (recipe.categories.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recipe.categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF576F5F),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Info Row (Time, Servings, Calories)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoItem(
                      icon: Icons.access_time_filled,
                      label: l10n.timeLabelUpper,
                      value: '${(recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0)} min',
                    ),
                    _InfoItem(
                      icon: Icons.restaurant_menu,
                      label: l10n.servingsLabelUpper,
                      value: '${recipe.baseServings ?? 1} ${l10n.servingShort}',
                    ),
                    _InfoItem(
                      icon: Icons.local_fire_department,
                      label: l10n.caloriesLabelUpper,
                      value: '${recipe.calories?.toInt() ?? 0} ${l10n.metricCalories}',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (!hideNutritionValues) ...[
                  Text(
                    l10n.nutritionPerServing,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1E1B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                       child: _NutritionCard(
                          label: l10n.metricProtein,
                          value: '${recipe.proteinGrams?.toInt() ?? 0}g',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NutritionCard(
                          label: l10n.metricFat,
                          value: '${recipe.fatsGrams?.toInt() ?? 0}g',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _NutritionCard(
                          label: l10n.metricCarbs,
                          value: '${recipe.carbsGrams?.toInt() ?? 0}g',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                Text(
                  l10n.descriptionTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1E1B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description.trim().isEmpty ? '-' : recipe.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF57635C),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Ingredients Section
                Row(
                  children: [
                    Text(
                      l10n.ingredientsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1E1B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.itemsCount(recipe.ingredients.length),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A9382),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recipe.ingredients.isEmpty)
                  Text(l10n.noIngredients, style: theme.textTheme.bodyLarge)
                else
                  ...recipe.ingredients.map((ingredient) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7A9382),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ingredient.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1E1B),
                              ),
                            ),
                          ),
                          Text(
                            '${ingredient.quantity?.toInt() ?? ''} ${ingredient.unit}',
                            style: const TextStyle(
                              color: Color(0xFF7A9382),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              showIngredientSubstituteFlow(
                                context: context,
                                ref: ref,
                                recipeId: widget.recipeId,
                                ingredient: ingredient,
                                hideNutritionValues: hideNutritionValues,
                                contextHint: recipe.name,
                              );
                            },
                            child: const Icon(Icons.sync, size: 20, color: Color(0xFF7A9382)),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 32),

                // Instructions Section
                Text(
                  l10n.instructionsTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1E1B),
                  ),
                ),
                const SizedBox(height: 16),
                if (recipe.instructions.trim().isEmpty)
                  Text(l10n.noInstructions, style: theme.textTheme.bodyLarge)
                else
                  ..._buildInstructions(recipe.instructions),
                const SizedBox(height: 100), // Space for bottom bar
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
                onPressed: () => ref.invalidate(recipeDetailProvider(widget.recipeId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: recipeAsync.maybeWhen(
        data: (recipe) => Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Shopping Cart Button (Always visible)
              _ActionButton(
                icon: Icons.shopping_cart_outlined,
                onPressed: () => _onAddToGroceryList(context, ref, recipe.id),
              ),
              const SizedBox(width: 12),

              // 2. Assistant Button
              if (widget.entryId == null || isCompleted)
                // Expanded Assistant if Complete is hidden
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/recipes/${widget.recipeId}/assistant'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7A9382),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.smart_toy_outlined, size: 22),
                    label: Text(
                      l10n.cookingAssistantTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else ...[
                // Small Assistant Circle
                _ActionButton(
                  icon: Icons.smart_toy_outlined,
                  onPressed: () => context.push('/recipes/${widget.recipeId}/assistant'),
                ),
                const SizedBox(width: 12),

                // 3. Complete Button
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _completeFromDetail(context, ref, recipe),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7A9382),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle, size: 22),
                    label: Text(
                      l10n.completeAction,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _completeFromDetail(BuildContext context, WidgetRef ref, dynamic recipe) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markCompleteDialogTitle),
        content: Text(l10n.markCompleteQuestion(recipe.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l10n.completeAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .bulkDeduct(
          widget.recipeId,
          recipe.baseServings ?? 1,
          entryId: widget.entryId,
        );
    
    if (!context.mounted) return;

    if (result != null) {
      setState(() {
        _currentStatus = 'completed';
      });

      if (widget.entryId != null) {
        // Find which plan to invalidate? For now, we might need a better way to refresh the caller screen.
        // Usually invalidating the specific entry provider works if it's being watched.
        ref.invalidate(mealPlanEntriesProvider); // Brute force refresh of entries if possible
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.missing.isEmpty
                ? l10n.mealCompletedSuccess(result.deducted.length)
                : l10n.mealCompletedMissing(result.missing.length),
          ),
        ),
      );
      // Wait a bit then pop
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.pop();
      });
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.mealCompletedError)),
      );
    }
  }

  List<Widget> _buildInstructions(String instructions) {
    final steps = instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value.trim().replaceFirst(RegExp(r'^\d+[\.\)\s]+'), '');
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7A9382),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF57635C),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _onAddToGroceryList(BuildContext context, WidgetRef ref, int recipeId) async {
    final l10n = AppLocalizations.of(context);
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
        .importRecipe(selectedId, recipeId);

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
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF7A9382).withValues(alpha: 0.6), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF7A9382), size: 28),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7A9382), size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFFA7BFAF),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1E1B),
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A9382),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF576F5F),
            ),
          ),
        ],
      ),
    );
  }
}
