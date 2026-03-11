import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

import 'package:meal_plan_app/features/grocery_list/presentation/widgets/edit_quantity_bottom_sheet.dart';

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
    final oldVal = _checked;
    final newVal = !oldVal;

    setState(() => _checked = newVal);
    _animController.forward().then((_) => _animController.reverse());

    final messenger = ScaffoldMessenger.of(context);
    final errorMsg = AppLocalizations.of(context).savedIngredientsFailed;

    try {
      await ref
          .read(groceryActionsProvider.notifier)
          .updateItem(widget.listId, widget.item.id, checked: newVal);
    } catch (e) {
      if (!mounted) return;
      setState(() => _checked = oldVal);
      messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: ScaleTransition(
              scale: _scaleAnim,
              child: GestureDetector(
                onTap: _toggleCheck,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _checked
                        ? const Color(0xFF6B8A6B)
                        : Colors.transparent,
                    border: Border.all(
                      color: _checked
                          ? const Color(0xFF6B8A6B)
                          : Colors.grey.shade400,
                      width: _checked ? 0 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _checked
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                decoration: _checked ? TextDecoration.lineThrough : null,
                color: _checked
                    ? Colors.blueGrey.shade300
                    : const Color(0xFF334139),
              ),
              child: Text(widget.item.ingredientName),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${_formatQty(widget.item.quantity)} ${widget.item.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blueGrey.shade400,
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
                      l10n.groceryItemInPantry,
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
              icon: const Icon(Icons.mode_edit_outline_outlined, size: 18, color: Color(0xFF7BA082)),
              tooltip: l10n.groceryItemEditTooltip,
              onPressed: () => _showEditQuantity(context),
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
  }

  Future<void> _showEditQuantity(BuildContext context) async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditQuantityBottomSheet(
        initialQuantity: widget.item.quantity,
        ingredientName: widget.item.ingredientName,
        unit: widget.item.unit,
      ),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final errorMsg = l10n.savedIngredientsFailed;
      try {
        await ref
            .read(groceryActionsProvider.notifier)
            .updateItem(widget.listId, widget.item.id, quantity: result);
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }
}

