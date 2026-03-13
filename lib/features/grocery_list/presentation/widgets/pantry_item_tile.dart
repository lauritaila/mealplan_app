import 'package:flutter/material.dart';
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
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onEdit,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F1), // Light greenish background
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco_outlined, // Generic food icon
              color: Color(0xFF5A7258),
              size: 24,
            ),
          ),
          title: Text(
            item.ingredientName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF151B26),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                if (isExpired)
                  Text(
                    AppLocalizations.of(context).pantryItemExpired,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (expiringSoon)
                  Text(
                    AppLocalizations.of(context).pantryExpiringSoon,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    AppLocalizations.of(context).pantryStatusValid,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_formatQty(item.quantity)} ${item.unit}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF334139),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);
  }
}
