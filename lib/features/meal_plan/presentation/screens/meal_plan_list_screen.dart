import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanListScreen extends ConsumerWidget {
  const MealPlanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(mealPlansProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPlansTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => context.push('/meal-plan/current'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(mealPlansProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meal-plan/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newPlan),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(e.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(mealPlansProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSavedPlans,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.createFirstPlan),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/meal-plan/new'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newPlan),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _MealPlanCard(plan: plan);
            },
          );
        },
      ),
    );
  }
}

class _MealPlanCard extends ConsumerWidget {
  final MealPlanSummary plan;
  const _MealPlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final df = DateFormat('d MMM', Localizations.localeOf(context).toString());
    final dateRange =
        '${df.format(plan.startDate)} – ${df.format(plan.endDate)} ${plan.endDate.year}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/meal-plan/${plan.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.planName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (plan.generatedByAi)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.ai,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _onMenuAction(context, ref, value),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: const Icon(Icons.calendar_view_week_outlined),
                      title: Text(l10n.menuViewEntries),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined),
                      title: Text(l10n.menuSaveIngredients),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'reuse',
                    child: ListTile(
                      leading: const Icon(Icons.replay_outlined),
                      title: Text(l10n.menuReusePlan),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.red),
                      title: Text(
                        l10n.deleteAction,
                        style: const TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'view':
        context.push('/meal-plan/${plan.id}');
      case 'import':
        await _importToList(context, ref, l10n);
      case 'reuse':
        await _showReusePlanSheet(context, ref, l10n);
      case 'delete':
        await _showDeletePlanDialog(context, ref, l10n);
    }
  }

  Future<void> _importToList(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final selected = await showSelectOrCreateGroceryListSheet(
      context: context,
      ref: ref,
      title: l10n.saveIngredientsSheetTitle,
    );
    if (selected == null) return;
    final ok = await ref
        .read(groceryActionsProvider.notifier)
        .importMealPlan(selected.id, plan.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            ok
              ? l10n.savedIngredientsSuccess(selected.name)
              : l10n.savedIngredientsFailed,
        ),
      ),
    );
  }

  Future<void> _showReusePlanSheet(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final result =
        await showModalBottomSheet<({String startDate, String? name})>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _ReusePlanSheet(plan: plan),
        );
    if (result == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final response = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .reusePlan(plan.id, result.startDate, name: result.name);
    if (!context.mounted) return;
    if (response != null) {
      ref.invalidate(mealPlansProvider);
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              l10n.planReusedSuccess(response.newPlanName, response.entriesCloned),
          ),
          action: SnackBarAction(
            label: l10n.planReusedView,
            onPressed: () => context.push('/meal-plan/${response.newPlanId}'),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.planReusedFailed)),
      );
    }
  }

  Future<void> _showDeletePlanDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    bool removeShoppingList = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(l10n.deletePlanDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deletePlanDialogMessage),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: removeShoppingList,
                onChanged: (v) =>
                    setLocalState(() => removeShoppingList = v ?? false),
                title: Text(l10n.deletePlanAlsoRemoveGrocery),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.deleteAction),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .deletePlan(plan.id, removeShoppingList: removeShoppingList);
    if (!context.mounted) return;
    final state = ref.read(mealPlanEntryActionsProvider);
    if (state.status == MealPlanEntryActionStatus.success) {
      ref.invalidate(mealPlansProvider);
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
      messenger.showSnackBar(SnackBar(content: Text(l10n.planDeletedSuccess)));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? l10n.planDeleteFailed),
        ),
      );
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    }
  }
}

// ── Reuse Plan Bottom Sheet ──────────────────────────────────────────────────

class _ReusePlanSheet extends StatefulWidget {
  final MealPlanSummary plan;
  const _ReusePlanSheet({required this.plan});

  @override
  State<_ReusePlanSheet> createState() => _ReusePlanSheetState();
}

class _ReusePlanSheetState extends State<_ReusePlanSheet> {
  DateTime? _selectedDate;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final df = DateFormat('d MMM yyyy', Localizations.localeOf(context).toString());

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reusePlanSheetTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '"${widget.plan.planName}"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.reusePlanStartDateLabel,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _selectedDate == null
                  ? l10n.reusePlanSelectDate
                  : df.format(_selectedDate!),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.reusePlanNameLabel,
              hintText: l10n.reusePlanNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedDate == null ? null : _onConfirm,
            icon: const Icon(Icons.replay_outlined),
            label: Text(l10n.menuReusePlan),
          ),
        ],
      ),
    );
  }

  void _onConfirm() {
    if (_selectedDate == null) return;
    final dateStr =
        '${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    Navigator.of(context).pop((
      startDate: dateStr,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
    ));
  }
}
