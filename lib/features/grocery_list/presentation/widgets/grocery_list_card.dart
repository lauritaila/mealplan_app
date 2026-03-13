import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/domain/entities/grocery_list.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: Key('grocery-list-${list.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Text(
              l10n.deleteGroceryListDialogTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
            content: Text(
              l10n.deleteGroceryListDialogMessage(list.name),
              style: textTheme.bodyMedium?.copyWith(
                color: customColors.slateGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: customColors.slateGrey, fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.deleteAction, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: customColors.darkSage?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_basket_outlined, color: customColors.darkSage, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: textTheme.titleMedium?.copyWith(
                        color: customColors.textDarkBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (list.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(list.createdAt!, context),
                        style: textTheme.bodySmall?.copyWith(
                          color: customColors.slateGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: customColors.slateGrey?.withValues(alpha: 0.3),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    return DateFormat('d MMM y', Localizations.localeOf(context).toString()).format(date);
  }
}
