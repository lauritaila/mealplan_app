import 'package:collection/collection.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';

import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/utils/ingredient_substitute_flow.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_info_item.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_nutrition_card.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_ingredient_tile.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_instruction_step.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/recipe_bottom_action_button.dart';

import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    final isCompleted = _currentStatus?.toLowerCase() == 'completed';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.recipeDetailTitle,
          style: textTheme.titleLarge?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: IconThemeData(color: customColors.textDarkBlue),
        actions: [
          recipeAsync.maybeWhen(
            data: (recipe) => IconButton(
              icon: Icon(
                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: recipe.isFavorite ? Colors.red : customColors.slateGrey,
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(toggleFavoriteProvider.notifier)
                      .toggle(widget.recipeId);
                } catch (e) {
                  if (!context.mounted) return;
                  CustomSnackbar.showError(context, l10n.favoriteUpdateFailed);
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                if (recipe.categories.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recipe.categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: customColors.chartTabBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: textTheme.labelSmall?.copyWith(
                            color: customColors.darkSage,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RecipeInfoItem(
                      icon: Icons.access_time_filled,
                      label: l10n.timeLabelUpper,
                      value: '${(recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0)} min',
                    ),
                    RecipeInfoItem(
                      icon: Icons.restaurant_menu,
                      label: l10n.servingsLabelUpper,
                      value: '${recipe.baseServings ?? 1} ${l10n.servingShort}',
                    ),
                    if (!hideNutritionValues)
                      RecipeInfoItem(
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
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: customColors.textDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                       child: RecipeNutritionCard(
                          label: l10n.metricProtein,
                          value: '${recipe.proteinGrams?.toInt() ?? 0}g',
                          labelColor: customColors.macroProtein,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RecipeNutritionCard(
                          label: l10n.metricFat,
                          value: '${recipe.fatsGrams?.toInt() ?? 0}g',
                          labelColor: customColors.macroFat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RecipeNutritionCard(
                          label: l10n.metricCarbs,
                          value: '${recipe.carbsGrams?.toInt() ?? 0}g',
                          labelColor: customColors.macroCarbs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                Text(
                  l10n.descriptionTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: customColors.textDarkBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recipe.description.trim().isEmpty ? '-' : recipe.description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: customColors.slateGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Text(
                      l10n.ingredientsTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: customColors.textDarkBlue,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.itemsCount(recipe.ingredients.length),
                      style: textTheme.labelMedium?.copyWith(
                        color: customColors.darkSage,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recipe.ingredients.isEmpty)
                  Text(l10n.noIngredients, style: textTheme.bodyLarge)
                else
                  ...recipe.ingredients.map((ingredient) {
                    return RecipeIngredientTile(
                      ingredient: ingredient,
                      onSubstitute: () {
                        showIngredientSubstituteFlow(
                          context: context,
                          ref: ref,
                          recipeId: widget.recipeId,
                          ingredient: ingredient,
                          hideNutritionValues: hideNutritionValues,
                          contextHint: recipe.name,
                        );
                      },
                    );
                  }),
                const SizedBox(height: 32),

                Text(
                  l10n.instructionsTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: customColors.textDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                if (recipe.instructions.trim().isEmpty)
                  Text(l10n.noInstructions, style: textTheme.bodyLarge)
                else
                  ..._buildInstructions(recipe.instructions),
                const SizedBox(height: 100),
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
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              RecipeBottomActionButton(
                icon: Icons.shopping_cart_outlined,
                onPressed: () => _onAddToGroceryList(ref, recipe.id),
              ),
              const SizedBox(width: 12),

              if (widget.entryId == null || isCompleted)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/recipes/${widget.recipeId}/assistant'),
                    style: FilledButton.styleFrom(
                      backgroundColor: customColors.darkSage,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.smart_toy_outlined, size: 24),
                    label: Text(
                      l10n.cookingAssistantTitle.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                )
              else ...[
                RecipeBottomActionButton(
                  icon: Icons.smart_toy_outlined,
                  onPressed: () => context.push('/recipes/${widget.recipeId}/assistant'),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _completeFromDetail(ref, recipe),
                    style: FilledButton.styleFrom(
                      backgroundColor: customColors.darkSage,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      l10n.completeAction.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
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

  Future<void> _completeFromDetail(WidgetRef ref, dynamic recipe) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.markCompleteDialogTitle,
          style: TextStyle(fontWeight: FontWeight.w900, color: customColors.textDarkBlue),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.markCompleteQuestion(recipe.name),
              style: TextStyle(color: customColors.slateGrey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.markCompleteDeductInfo,
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w800, color: customColors.slateGrey),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: customColors.darkSage,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              l10n.completeAction.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .bulkDeduct(
          widget.recipeId,
          recipe.baseServings ?? 1,
          entryId: widget.entryId,
        );
    
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _currentStatus = 'completed';
      });

      if (widget.entryId != null) {
        ref.invalidate(mealPlanEntriesProvider);
      }
      CustomSnackbar.showSuccess(
        context,
        result.missing.isEmpty
            ? l10n.mealCompletedSuccess(result.deducted.length)
            : l10n.mealCompletedMissing(result.missing.length),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) navigator.pop();
      });
    } else {
      CustomSnackbar.showError(context, l10n.mealCompletedError);
    }
  }

  List<Widget> _buildInstructions(String instructions) {
    final steps = instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value.trim().replaceFirst(RegExp(r'^\d+[\.\)\s]+'), '');
      return RecipeInstructionStep(index: index, text: text);
    }).toList();
  }

  Future<void> _onAddToGroceryList(WidgetRef ref, int recipeId) async {
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

    if (selectedId == null || !mounted) return;

    final ok = await ref
        .read(groceryActionsProvider.notifier)
        .importRecipe(selectedId, recipeId);

    if (!mounted) return;

    String? listName;
    final lists = ref.read(groceryListsProvider).asData?.value;
    if (lists != null) {
      listName = lists.firstWhereOrNull((l) => l.id == selectedId)?.name;
    }

    CustomSnackbar.showInfo(context, 
          ok
              ? l10n.recipeAddedToList(listName ?? l10n.groceryTitle)
              : l10n.recipeAddFailed,
        );
  }
}
