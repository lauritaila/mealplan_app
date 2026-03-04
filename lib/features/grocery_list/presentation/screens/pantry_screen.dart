import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/pantry_item.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/add_item_bottom_sheet.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/pantry_item_tile.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryItemsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mi despensa'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(pantryItemsProvider),
        child: pantryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => ref.refresh(pantryItemsProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyPantry();
            }

            // Group by category
            final grouped = <String, List<PantryItem>>{};
            for (final item in items) {
              final cat = (item.category?.isNotEmpty == true)
                  ? item.category!
                  : 'Otros';
              grouped.putIfAbsent(cat, () => []).add(item);
            }
            final categories = grouped.keys.toList()..sort();

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: categories.fold<int>(
                0,
                (sum, cat) => sum + 1 + (grouped[cat]?.length ?? 0),
              ),
              itemBuilder: (ctx, index) {
                int cursor = 0;
                for (final cat in categories) {
                  if (index == cursor) {
                    return _CategoryHeader(label: cat);
                  }
                  cursor++;
                  final catItems = grouped[cat]!;
                  if (index < cursor + catItems.length) {
                    final item = catItems[index - cursor];
                    return PantryItemTile(
                      key: Key('pantry-${item.id}'),
                      item: item,
                      onEdit: () => _showEditPantryItem(context, ref, item),
                      onDelete: () => ref
                          .read(pantryActionsProvider.notifier)
                          .deleteItem(item.id),
                    );
                  }
                  cursor += catItems.length;
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pantry-fab',
        tooltip: 'Agregar a la despensa',
        onPressed: () => _showAddItem(context),
        child: const Icon(Icons.add),
      ),
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
      builder: (_) => const AddItemBottomSheet(listId: null),
    );
  }

  Future<void> _showEditPantryItem(
    BuildContext context,
    WidgetRef ref,
    PantryItem item,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => _EditPantryItemDialog(item: item, ref: ref),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  const _CategoryHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _EmptyPantry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 72,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'La despensa está vacía',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega ingredientes que ya tienes en casa',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditPantryItemDialog extends StatefulWidget {
  final PantryItem item;
  final WidgetRef ref;
  const _EditPantryItemDialog({required this.item, required this.ref});

  @override
  State<_EditPantryItemDialog> createState() => _EditPantryItemDialogState();
}

class _EditPantryItemDialogState extends State<_EditPantryItemDialog> {
  late final TextEditingController _quantityCtrl;
  DateTime? _expiryDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final q = widget.item.quantity;
    _quantityCtrl = TextEditingController(
      text: q == q.roundToDouble()
          ? q.toInt().toString()
          : q.toStringAsFixed(2),
    );
    _expiryDate = widget.item.expiresAt;
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = double.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty <= 0) return;
    setState(() => _loading = true);
    final expiresAt = _expiryDate != null
        ? _expiryDate!.toIso8601String().split('T').first
        : null;
    await widget.ref
        .read(pantryActionsProvider.notifier)
        .updateItem(widget.item.id, quantity: qty, expiresAt: expiresAt);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final dateLabel = _expiryDate != null
        ? '${_expiryDate!.day} de ${months[_expiryDate!.month - 1]} de ${_expiryDate!.year}'
        : 'Sin fecha';

    return AlertDialog(
      title: Text('Editar ${widget.item.ingredientName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Cantidad'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Vence',
                suffixIcon: _expiryDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _expiryDate = null),
                      )
                    : const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(dateLabel, style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
