import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanEntriesScreen extends ConsumerWidget {
  final int planId;
  final String? planName;

  const MealPlanEntriesScreen({super.key, required this.planId, this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesProvider(planId));
    final actionsState = ref.watch(mealPlanEntryActionsProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;
    final userPermissions = authState is AuthenticatedAuthState
        ? authState.user.permissions?.permissions
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(planName ?? 'Entradas del plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(mealPlanEntriesProvider(planId)),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                localizeErrorCode(l10n, error is AppError ? error.code : null),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(mealPlanEntriesProvider(planId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No hay entradas en este plan.'));
          }

          // Group entries by date
          final grouped = <DateTime, List<DayMealEntry>>{};
          for (final e in entries) {
            final date = e.mealDate != null
                ? DateTime(e.mealDate!.year, e.mealDate!.month, e.mealDate!.day)
                : DateTime(2000);
            grouped.putIfAbsent(date, () => []).add(e);
          }
          final sortedDates = grouped.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: sortedDates.length,
            itemBuilder: (context, di) {
              final date = sortedDates[di];
              final dayEntries = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (di > 0) const SizedBox(height: 8),
                  _DateHeader(date: date),
                  const SizedBox(height: 8),
                  ...dayEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanEntryCard(
                        entry: entry,
                        hideNutritionValues: hideNutritionValues,
                        isUpdating:
                            actionsState.status ==
                            MealPlanEntryActionStatus.loading,
                        userPermissions: userPermissions,
                        planId: planId,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    if (date.year == 2000) return const SizedBox.shrink();
    final df = DateFormat('EEEE, d MMMM', 'es');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        df.format(date).toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _PlanEntryCard extends ConsumerWidget {
  final DayMealEntry entry;
  final bool hideNutritionValues;
  final bool isUpdating;
  final PermissionDetails? userPermissions;
  final int planId;

  const _PlanEntryCard({
    required this.entry,
    required this.hideNutritionValues,
    required this.isUpdating,
    required this.userPermissions,
    required this.planId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCompleted = entry.status?.toLowerCase() == 'completed';

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: entry.recipeId > 0
            ? () => context.push(
                '/recipes/${entry.recipeId}?entryId=${entry.entryId}',
              )
            : null,
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
                        if (entry.mealType != null &&
                            entry.mealType!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.mealType!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (!hideNutritionValues && entry.calories != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${entry.calories!.round()} kcal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: !isUpdating,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _onMenuAction(context, ref, value),
                itemBuilder: (_) => [
                  if (entry.recipeId > 0)
                    const PopupMenuItem(
                      value: 'view_recipe',
                      child: ListTile(
                        leading: Icon(Icons.receipt_long_outlined),
                        title: Text('Ver receta'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'import_recipe',
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart_outlined),
                      title: Text('Agregar a lista de compras'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (!isCompleted)
                    const PopupMenuItem(
                      value: 'complete',
                      child: ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        title: Text('Marcar como completada'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
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
    String action,
  ) async {
    if (action == 'view_recipe') {
      context.push('/recipes/${entry.recipeId}?entryId=${entry.entryId}');
    } else if (action == 'import_recipe') {
      await _importRecipeToList(context, ref, recipeId: entry.recipeId);
    } else if (action == 'complete') {
      // Keep original action name for now
      await _confirmComplete(context, ref);
    } else if (action == 'delete') {
      // Keep original action name for now
      await _confirmDelete(context, ref);
    }
  }

  Future<void> _importRecipeToList(
    BuildContext context,
    WidgetRef ref, {
    required int recipeId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final selected = await showSelectOrCreateGroceryListSheet(
      context: context,
      ref: ref,
      title: 'Agregar receta a lista',
    );
    if (selected == null) return;
    final ok = await ref
        .read(groceryActionsProvider.notifier)
        .importRecipe(selected.id, entry.recipeId);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Receta agregada a "${selected.name}"'
              : 'No se pudo agregar la receta',
        ),
      ),
    );
  }

  Future<void> _confirmComplete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marcar como completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Completaste "${entry.name}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Los ingredientes de esta receta se descontarán automáticamente de tu despensa.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Completar'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .bulkDeduct(
          entry.recipeId,
          entry.servings ?? 1,
          entryId: entry.entryId,
        );
    if (!context.mounted) return;
    ref.invalidate(mealPlanEntriesProvider(planId));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
    if (result != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.missing.isEmpty
                ? '✅ ¡Listo! ${result.deducted.length} ingredientes descontados.'
                : '✅ Completado. ${result.missing.length} ingredientes no estaban en tu despensa.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    bool removeShoppingList = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(l10n.deleteMealDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.deleteMealDialogMessage),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: removeShoppingList,
                onChanged: (v) =>
                    setLocalState(() => removeShoppingList = v ?? false),
                title: const Text('Eliminar también de la lista de la compra'),
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
        .deleteEntry(entry.entryId, removeShoppingList: removeShoppingList);
    if (!context.mounted) return;
    final state = ref.read(mealPlanEntryActionsProvider);
    if (state.status == MealPlanEntryActionStatus.success) {
      ref.invalidate(mealPlanEntriesProvider(planId));
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    } else if (state.status == MealPlanEntryActionStatus.error) {
      messenger.showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? l10n.genericDeleteError)),
      );
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    }
  }
}
