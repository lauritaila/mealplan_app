import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/pantry_item.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/pantry_item_tile.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/edit_pantry_item_dialog.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/pantry_category_header.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(groupedPantryItemsProvider);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: customColors.darkSage,
        onRefresh: () async => await ref.refresh(pantryItemsProvider.future),
        child: groupedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => AppErrorState(
            message: e.toString(),
            onRetry: () => ref.refresh(pantryItemsProvider),
          ),
          data: (displayItems) {
            if (displayItems.isEmpty) {
              return AppEmptyState(
                title: l10n.pantryEmptyTitle,
                subtitle: l10n.pantryEmptySubtitle,
                icon: Icons.kitchen_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: displayItems.length,
              itemBuilder: (ctx, index) {
                final displayItem = displayItems[index];

                if (displayItem is PantryHeaderDisplayItem) {
                  final label = displayItem.category == '__other__'
                      ? l10n.pantryOtherCategory
                      : displayItem.category;
                  return PantryCategoryHeader(label: label);
                }

                if (displayItem is PantryItemDisplayItem) {
                  final item = displayItem.item;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: PantryItemTile(
                      key: Key('pantry-${item.id}'),
                      item: item,
                      onEdit: () => _showEditPantryItem(context, item),
                      onDelete: () => ref.read(pantryActionsProvider.notifier).deleteItem(item.id),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pantry-fab',
        tooltip: l10n.pantryAddTooltip,
        onPressed: () => _showAddItem(context),
        backgroundColor: customColors.darkSage,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Future<void> _showAddItem(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => const AddItemBottomSheet(listId: null),
    );
  }

  Future<void> _showEditPantryItem(BuildContext context, PantryItem item) async {
    await showDialog(
      context: context,
      builder: (_) => EditPantryItemDialog(item: item),
    );
  }
}
