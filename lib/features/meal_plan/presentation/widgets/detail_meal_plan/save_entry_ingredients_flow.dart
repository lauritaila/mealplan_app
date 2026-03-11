import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/widgets/select_list_sheet.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class SaveEntryIngredientsFlow {
  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
    required int recipeId,
  }) async {
    final l10n = AppLocalizations.of(context);

    // Skip confirmation dialog and go straight to selecting list
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
          .importRecipe(selectedId, recipeId);

      if (context.mounted) {
        String? listName;
        final lists = ref.read(groceryListsProvider).asData?.value;
        if (lists != null) {
          try {
            listName = lists.firstWhere((l) => l.id == selectedId).name;
          } catch (_) {
            listName = null;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? l10n.recipeAddedToList(listName ?? 'la lista')
                  : l10n.recipeAddFailed,
            ),
          ),
        );
      }
    }
  }
}
