import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/recipe_repository_provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/ingredient_substitutes_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
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
  final authState = ref.read(authProvider);
  
  bool isFree = true;
  if (authState is AuthenticatedAuthState) {
    final planName = authState.user.planName?.toLowerCase() ?? 'free';
    isFree = planName == 'free';
  }

  if (isFree) {
    if (!context.mounted) return;
    context.push(
      '/premium',
      extra: {
        'title': l10n.premiumFeatureTitle,
        'message': l10n.cookingAssistantPremiumMessage,
      },
    );
    return;
  }

  // Check substitution limits
  final canGen = await ref.read(canGenerateMealPlanProvider.future);
  if (!context.mounted) return;

  if (canGen.substituteRemaining <= 0) {
    context.push(
      '/premium',
      extra: {
        'title': l10n.premiumFeatureTitle,
        'message': l10n.substituteLimitReachedMessage,
      },
    );
    return;
  }

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
    CustomSnackbar.showInfo(context, l10n.substituteMissingIngredientId);
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.substituteConfirmTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B261B)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.substituteConfirmMessage,
              style: const TextStyle(color: Color(0xFF5A6B5A)),
            ),
            if (!hideNutritionValues) ...[
              const SizedBox(height: 12), // Corrected: Reverted to original SizedBox
              Text(
                l10n.substituteConfirmNutritionWarning,
                style: const TextStyle(
                  color: Color(0xFF8A9A8A),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF8A9A8A), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8), // Corrected: Removed `error: (error, stack) => const SizedBox.shrink(),`
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7A9382),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              l10n.applySubstituteAction,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFF4A614A)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                l10n.applyingSubstitute,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B261B),
                ),
              ),
            ),
          ],
        ),
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
    CustomSnackbar.showInfo(context, errorText);
  }
}
