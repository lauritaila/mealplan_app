import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GroceryItemTile extends ConsumerStatefulWidget {
  final GroceryListItem item;
  final int listId;
  final VoidCallback? onDelete;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.listId,
    this.onDelete,
  });

  @override
  ConsumerState<GroceryItemTile> createState() => _GroceryItemTileState();
}

class _GroceryItemTileState extends ConsumerState<GroceryItemTile>
    with SingleTickerProviderStateMixin {
  late bool _checked;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _checked = widget.item.checked;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(GroceryItemTile old) {
    super.didUpdateWidget(old);
    if (old.item.checked != widget.item.checked) {
      _checked = widget.item.checked;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleCheck() async {
    final newVal = !_checked;
    setState(() => _checked = newVal);
    _animController.forward().then((_) => _animController.reverse());
    await ref
        .read(groceryActionsProvider.notifier)
        .updateItem(widget.listId, widget.item.id, checked: newVal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coveredByPantry = widget.item.isCoveredByPantry;

    return Dismissible(
      key: Key('item-${widget.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => widget.onDelete?.call(),
      child: Opacity(
        opacity: coveredByPantry ? 0.55 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: ScaleTransition(
            scale: _scaleAnim,
            child: GestureDetector(
              onTap: _toggleCheck,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _checked
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: _checked
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _checked
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyLarge!.copyWith(
              decoration: _checked ? TextDecoration.lineThrough : null,
              color: _checked
                  ? theme.colorScheme.onSurface.withOpacity(0.45)
                  : theme.colorScheme.onSurface,
            ),
            child: Text(widget.item.ingredientName),
          ),
          subtitle: Row(
            children: [
              Text(
                '${_formatQty(widget.item.quantity)} ${widget.item.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (coveredByPantry) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'En despensa',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Editar cantidad',
            onPressed: () => _showEditQuantity(context),
          ),
        ),
      ),
    );
  }

  String _formatQty(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
  }

  Future<void> _showEditQuantity(BuildContext context) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _EditQuantityDialog(initial: widget.item.quantity),
    );
    if (result != null) {
      await ref
          .read(groceryActionsProvider.notifier)
          .updateItem(widget.listId, widget.item.id, quantity: result);
    }
  }
}

class _EditQuantityDialog extends StatefulWidget {
  final double initial;
  const _EditQuantityDialog({required this.initial});

  @override
  State<_EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<_EditQuantityDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initial == widget.initial.roundToDouble()
          ? widget.initial.toInt().toString()
          : widget.initial.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).editQuantityDialogTitle),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: AppLocalizations.of(context).addItemQuantityLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () {
            final val = double.tryParse(_ctrl.text.trim());
            if (val != null && val > 0) Navigator.pop(context, val);
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }
}
