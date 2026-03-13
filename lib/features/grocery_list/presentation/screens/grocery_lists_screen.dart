import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/screens/pantry_screen.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/create_list_dialog.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/grocery_list_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class GroceryListsScreen extends ConsumerWidget {
  const GroceryListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            l10n.grocerySectionTitle,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: customColors.darkSage,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: customColors.darkSage,
            unselectedLabelColor: customColors.slateGrey?.withValues(alpha: 0.5),
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
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
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: customColors.darkSage,
        onRefresh: () async {
          ref.invalidate(groceryListsProvider);
          await ref.read(groceryListsProvider.future);
        },
        child: listsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
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
                    l10n.groceryListsErrorLoading,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: customColors.textDarkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => ref.refresh(groceryListsProvider),
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
          data: (lists) {
            if (lists.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  alignment: Alignment.center,
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
                          Icons.shopping_basket_outlined,
                          size: 72,
                          color: customColors.slateGrey?.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.groceryListsEmptyTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          color: customColors.textDarkBlue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.groceryListsEmptySubtitle,
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
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: lists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                      CustomSnackbar.showError(context, l10n.genericDeleteError);
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          builder: (_) => const CreateListDialog(),
        ),
        backgroundColor: customColors.darkSage,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
