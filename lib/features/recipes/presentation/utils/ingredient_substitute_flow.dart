import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/ingredient_substitutes_sheet.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

Future<void> showIngredientSubstituteFlow({
  required BuildContext context,
  required WidgetRef ref,
  required int recipeId,
  required RecipeIngredient ingredient,
  required bool hideNutritionValues,
  required String contextHint,
}) async {
  final l10n = AppLocalizations.of(context);

  final selected = await showModalBottomSheet<IngredientSubstitute>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => IngredientSubstitutesSheet(
      recipeId: recipeId,
      request: IngredientSubstitutesRequest(
        ingredientOriginal: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        context: contextHint,
      ),
      ingredientName: ingredient.name,
    ),
  );

  if (!context.mounted) return;
  if (selected == null) return;

  if (ingredient.id == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.substituteMissingIngredientId)));
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.substituteConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.substituteConfirmMessage),
            if (!hideNutritionValues) ...[
              const SizedBox(height: 8),
              Text(l10n.substituteConfirmNutritionWarning),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.applySubstituteAction),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;
  if (confirmed != true) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(l10n.applyingSubstitute)),
        ],
      ),
    ),
  );

  try {
    final repository = ref.read(recipeRepositoryProvider);
    final result = await repository.applySubstitute(
      recipeId,
      ApplyRecipeSubstituteRequest(
        recipeIngredientId: ingredient.id!,
        substituteName: selected.name,
        ratio: selected.ratio,
        reason: selected.reason,
        category: selected.category,
      ),
    );

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    context.go('/recipes/${result.newRecipeId}');
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    final errorText = e is AppError
        ? localizeAppError(l10n, e)
        : l10n.genericError;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorText)));
  }
}
