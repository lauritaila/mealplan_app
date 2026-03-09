import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/pantry_item.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class PantryItemTile extends StatelessWidget {
  final PantryItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PantryItemTile({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isExpired =
        item.expiresAt != null && item.expiresAt!.isBefore(now);
    final expiringSoon =
        item.expiresAt != null &&
        !isExpired &&
        item.expiresAt!.difference(now).inDays <= 3;

    Color chipColor = theme.colorScheme.primaryContainer;
    Color chipTextColor = theme.colorScheme.onPrimaryContainer;
    if (isExpired) {
      chipColor = theme.colorScheme.errorContainer;
      chipTextColor = theme.colorScheme.onErrorContainer;
    } else if (expiringSoon) {
      chipColor = const Color(0xFFFFEDD8);
      chipTextColor = const Color(0xFF7C4A00);
    }

    return Dismissible(
      key: Key('pantry-${item.id}'),
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
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).pantryDeleteDialogTitle),
            content: Text(AppLocalizations.of(context).pantryDeleteDialogMessage(item.ingredientName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppLocalizations.of(context).deleteAction),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.kitchen_outlined,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          item.ingredientName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${_formatQty(item.quantity)} ${item.unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (item.category != null && item.category!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '· ${item.category}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.expiresAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isExpired
                      ? AppLocalizations.of(context).pantryItemExpired
                      : _formatDate(context, item.expiresAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: chipTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: AppLocalizations.of(context).editAction,
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  String _formatQty(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat('d MMM', Localizations.localeOf(context).toString())
        .format(date);
  }
}
