import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GroceryListCard extends StatelessWidget {
  final GroceryList list;
  final VoidCallback onTap;
  final Future<bool> Function()? onDelete;

  const GroceryListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key('grocery-list-${list.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context).deleteGroceryListDialogTitle),
            content: Text(AppLocalizations.of(context).deleteGroceryListDialogMessage(list.name)),
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

        if (confirmed == true && onDelete != null) {
          return await onDelete!.call();
        }
        return false;
      },
      onDismissed: (_) {},
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: const TextStyle(
                          color: Color(0xFF334139), // Dark green-grey
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (list.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(list.createdAt!, context),
                          style: TextStyle(
                            color: Colors.blueGrey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF7BA082),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    return DateFormat('d MMM y', Localizations.localeOf(context).toString()).format(date);
  }
}
