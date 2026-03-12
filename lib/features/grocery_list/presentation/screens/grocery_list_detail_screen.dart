import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/grocery_item_tile.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class GroceryListDetailScreen extends ConsumerWidget {
  final int listId;
  const GroceryListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(groceryListDetailProvider(listId));
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.errorTitle, style: TextStyle(color: customColors.textDarkBlue)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.genericError,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: customColors.textDarkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => ref.refresh(groceryListDetailProvider(listId)),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: customColors.darkSage,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (detail) {
        final checkedItems = detail.items.where((i) => i.checked).toList();
        final uncheckedItems = detail.items.where((i) => !i.checked).toList();

        int pantryCount = detail.items.where((i) => i.isCoveredByPantry).length;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              detail.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            actions: [
              if (pantryCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: customColors.darkSage?.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 16, color: customColors.darkSage),
                          const SizedBox(width: 8),
                          Text(
                            l10n.pantryCountLabel(pantryCount),
                            style: textTheme.labelSmall?.copyWith(
                              color: customColors.darkSage,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: customColors.darkSage,
            onRefresh: () async =>
                await ref.read(groceryListDetailProvider(listId).future),
            child: detail.items.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const _EmptyState(),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    children: [
                      // ── Unchecked items ──────────────────────────────────
                      if (uncheckedItems.isNotEmpty) ...[
                        _SectionHeader(
                          label: l10n.groceryListDetailPendingHeader,
                          count: uncheckedItems.length,
                        ),
                        ...uncheckedItems.map(
                          (item) => GroceryItemTile(
                            key: Key('item-${item.id}'),
                            item: item,
                            listId: listId,
                            onDelete: () => ref
                                .read(groceryActionsProvider.notifier)
                                .deleteItem(listId, item.id),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Checked items ────────────────────────────────────
                      if (checkedItems.isNotEmpty) ...[
                        _SectionHeader(
                          label: l10n.groceryListDetailCompletedHeader,
                          count: checkedItems.length,
                        ),
                        ...checkedItems.map(
                          (item) => GroceryItemTile(
                            key: Key('item-${item.id}'),
                            item: item,
                            listId: listId,
                            onDelete: () => ref
                                .read(groceryActionsProvider.notifier)
                                .deleteItem(listId, item.id),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'grocery-detail-fab',
            tooltip: l10n.addItemTitleGrocery,
            onPressed: () => _showAddItem(context),
            backgroundColor: customColors.darkSage,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.add, size: 32),
          ),
        );
      },
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
      builder: (_) => AddItemBottomSheet(listId: listId),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: customColors.slateGrey?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.darkSage,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: customColors.chartTabBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add_outlined,
                size: 72,
                color: customColors.slateGrey?.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.groceryListDetailEmptyTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: customColors.textDarkBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.groceryListDetailEmptySubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: customColors.slateGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
