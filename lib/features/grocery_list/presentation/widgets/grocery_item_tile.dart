import 'package:flutter/material.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
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

    final errorMsg = AppLocalizations.of(context).savedIngredientsFailed;

    try {
      await ref
          .read(groceryActionsProvider.notifier)
          .updateItem(widget.listId, widget.item.id, checked: newVal);
    } catch (e) {
      if (!mounted) return;
      setState(() => _checked = oldVal);
      CustomSnackbar.showError(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final coveredByPantry = widget.item.isCoveredByPantry;

    return Dismissible(
      key: Key('item-${widget.item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => widget.onDelete?.call(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: coveredByPantry ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _checked ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            leading: ScaleTransition(
              scale: _scaleAnim,
              child: GestureDetector(
                onTap: _toggleCheck,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _checked
                        ? customColors.darkSage
                        : customColors.chartTabBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _checked
                          ? customColors.darkSage!
                          : customColors.slateGrey!.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                  child: _checked
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w700,
                decoration: _checked ? TextDecoration.lineThrough : null,
                color: _checked
                    ? customColors.slateGrey?.withValues(alpha: 0.4)
                    : customColors.textDarkBlue,
              ),
              child: Text(widget.item.ingredientName),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${_formatQty(widget.item.quantity)} ${widget.item.unit}',
                  style: textTheme.bodySmall?.copyWith(
                    color: customColors.slateGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (coveredByPantry) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: customColors.darkSage?.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.groceryItemInPantry,
                      style: textTheme.labelSmall?.copyWith(
                        color: customColors.darkSage,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.mode_edit_outline_outlined,
                size: 20,
                color: customColors.slateGrey?.withValues(alpha: 0.4),
              ),
              tooltip: l10n.groceryItemEditTooltip,
              onPressed: _showEditQuantity,
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
  }

  Future<void> _showEditQuantity() async {
    final l10n = AppLocalizations.of(context);


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
      final errorMsg = l10n.savedIngredientsFailed;
      try {
        await ref
            .read(groceryActionsProvider.notifier)
            .updateItem(widget.listId, widget.item.id, quantity: result);
      } catch (e) {
        if (!mounted) return;
        CustomSnackbar.showError(context, errorMsg);
      }
    }
  }
}
