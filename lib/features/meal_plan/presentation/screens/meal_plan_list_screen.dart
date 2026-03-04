import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

class MealPlanListScreen extends ConsumerWidget {
  const MealPlanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(mealPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis planes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(mealPlansProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meal-plan/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo plan'),
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
                child: const Text('Reintentar'),
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
                    'No tienes planes guardados',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Crea tu primer plan de comidas.'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/meal-plan/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo plan'),
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
    final df = DateFormat('d MMM', 'es');
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
                                  'IA',
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
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.calendar_view_week_outlined),
                      title: Text('Ver entradas'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart_outlined),
                      title: Text('Guardar ingredientes'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reuse',
                    child: ListTile(
                      leading: Icon(Icons.replay_outlined),
                      title: Text('Reutilizar plan'),
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
    String value,
  ) async {
    switch (value) {
      case 'view':
        context.push('/meal-plan/${plan.id}');
      case 'import':
        await _importToList(context, ref);
      case 'reuse':
        await _showReusePlanSheet(context, ref);
      case 'delete':
        await _showDeletePlanDialog(context, ref);
    }
  }

  Future<void> _importToList(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final selected = await showSelectOrCreateGroceryListSheet(
      context: context,
      ref: ref,
      title: 'Guardar ingredientes del plan',
    );
    if (selected == null) return;
    final ok = await ref
        .read(groceryActionsProvider.notifier)
        .importMealPlan(selected.id, plan.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Ingredientes guardados en "${selected.name}"'
              : 'No se pudo guardar los ingredientes',
        ),
      ),
    );
  }

  Future<void> _showReusePlanSheet(BuildContext context, WidgetRef ref) async {
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
            '¡Plan reutilizado! "${response.newPlanName}" con ${response.entriesCloned} comidas.',
          ),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () => context.push('/meal-plan/${response.newPlanId}'),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo reutilizar el plan')),
      );
    }
  }

  Future<void> _showDeletePlanDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    bool removeShoppingList = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('¿Eliminar plan?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Esta acción no se puede deshacer.'),
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
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Eliminar'),
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
      messenger.showSnackBar(const SnackBar(content: Text('Plan eliminado')));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'No se pudo eliminar el plan'),
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
    final df = DateFormat('d MMM yyyy', 'es');

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
                  'Reutilizar plan',
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
            'Fecha de inicio (requerida)',
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
                  ? 'Seleccionar fecha'
                  : df.format(_selectedDate!),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del nuevo plan (opcional)',
              hintText: 'Ej: Semana del 17 de marzo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedDate == null ? null : _onConfirm,
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Reutilizar'),
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
