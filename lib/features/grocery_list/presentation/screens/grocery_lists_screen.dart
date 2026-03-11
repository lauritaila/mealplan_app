import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/screens/pantry_screen.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/create_list_dialog.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/grocery_list_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GroceryListsScreen extends ConsumerWidget {
  const GroceryListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            l10n.grocerySectionTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          // backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: const Color(0xFF5A7258),
            indicatorWeight: 3,
            labelColor: const Color(0xFF5A7258),
            unselectedLabelColor: Colors.blueGrey.shade300,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: [
              Tab(text: l10n.groceryListsTab),
              Tab(text: l10n.pantryTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GroceryListsTab(),
            PantryScreen(),
          ],
        ),
      ),
    );
  }
}

class _GroceryListsTab extends ConsumerWidget {
  const _GroceryListsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(groceryListsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(groceryListsProvider);
          await ref.read(groceryListsProvider.future);
        },
        child: listsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  l10n.groceryListsErrorLoading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => ref.refresh(groceryListsProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (lists) {
            if (lists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.groceryListsEmptyTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.groceryListsEmptySubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: lists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final list = lists[i];
                return GroceryListCard(
                  list: list,
                  onTap: () => context.push('/grocery-list/${list.id}'),
                  onDelete: () async {
                    try {
                      await ref
                          .read(groceryActionsProvider.notifier)
                          .deleteList(list.id);
                      return true;
                    } catch (e) {
                      if (!context.mounted) return false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.genericDeleteError),
                        ),
                      );
                      return false;
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'grocery-lists-fab',
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const CreateListDialog(),
        ),
        backgroundColor: const Color(0xFF6B8A6B),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
