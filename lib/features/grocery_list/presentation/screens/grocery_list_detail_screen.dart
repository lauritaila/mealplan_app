import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/grocery_item_tile.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GroceryListDetailScreen extends ConsumerWidget {
  final int listId;
  const GroceryListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(groceryListDetailProvider(listId));
    final theme = Theme.of(context);

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(backgroundColor: theme.colorScheme.surface),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).errorTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context).genericError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.refresh(groceryListDetailProvider(listId)),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
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
            title: Text(detail.name),
            centerTitle: false,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              if (pantryCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: Icon(
                      Icons.kitchen_outlined,
                      size: 16,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    label: Text(
                      AppLocalizations.of(context).pantryCountLabel(pantryCount),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(groceryListDetailProvider(listId)),
            child: detail.items.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(listId: listId),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      // ── Unchecked items ──────────────────────────────────
                      if (uncheckedItems.isNotEmpty) ...[
                        _SectionHeader(
                          label: AppLocalizations.of(context).groceryListDetailPendingHeader,
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
                          label: AppLocalizations.of(context).groceryListDetailCompletedHeader,
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

                      const SizedBox(height: 80),
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'grocery-detail-fab',
            tooltip: AppLocalizations.of(context).addItemTitleGrocery,
            onPressed: () => _showAddItem(context),
            child: const Icon(Icons.add),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int listId;
  const _EmptyState({required this.listId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_add_outlined,
            size: 72,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.groceryListDetailEmptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.groceryListDetailEmptySubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
