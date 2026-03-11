import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
// unused
import 'package:meal_plan_app/features/shared/widgets/select_list_sheet.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class SaveIngredientsFlow {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required int planId,
    bool skipInitialDialog = false,
  }) async {
    final l10n = AppLocalizations.of(context);

    bool wantsToSave = skipInitialDialog;

    // 1. Show modal asking if user wants to save ingredients
    if (!wantsToSave) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F7F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.playlist_add_check_rounded,
                    color: Color(0xFF576F5F),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.saveIngredientsSheetTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1E1B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.saveIngredientsDialogContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF576F5F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    l10n.yesSaveAction,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F7F9),
                    foregroundColor: const Color(0xFF576F5F),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.notNowAction,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      wantsToSave = result == true;
    }

    if (wantsToSave && context.mounted) {
      // 2. Show list selection sheet
      final selectedId = await showModalBottomSheet<int?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SelectListSheet(
          title: l10n.selectListTitle ?? 'Seleccionar Lista',
          subtitle: l10n.selectListSubtitle ?? 'Elige dónde guardar tus artículos',
        ),
      );

      if (selectedId != null && context.mounted) {
        final ok = await ref
            .read(groceryActionsProvider.notifier)
            .importMealPlan(selectedId, planId);

        if (context.mounted) {
          String? listName;
          final lists = ref.read(groceryListsProvider).asData?.value;
          if (lists != null) {
            listName = lists.firstWhere((l) => l.id == selectedId).name;
          }

          CustomSnackbar.showInfo(context, 
                ok
                    ? l10n.savedIngredientsSuccess(listName ?? 'la lista')
                    : l10n.savedIngredientsFailed,
              );
        }
      }
    }

    // 3. Navigate home only if we are in the flow where dialog was shown
    if (!skipInitialDialog && context.mounted) {
      context.go('/home');
    }
  }
}
