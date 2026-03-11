import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? const Color(0xFFE57373) : const Color(0xFF1A1E1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EntryActionsSheet extends ConsumerWidget {
  final DayMealEntry entry;
  final VoidCallback onToggleSkipped;
  final VoidCallback onImportRecipeToList;
  final VoidCallback onDeleteEntry;
  final VoidCallback onRegenerateEntry;
  final VoidCallback onSwapRecipe;
  final VoidCallback onChangeDate;

  const EntryActionsSheet({
    super.key,
    required this.entry,
    required this.onToggleSkipped,
    required this.onImportRecipeToList,
    required this.onDeleteEntry,
    required this.onRegenerateEntry,
    required this.onSwapRecipe,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isSkipped = _isSkippedStatus(entry.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            entry.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1E1B),
            ),
          ),
          if (entry.mealType != null) ...[
            const SizedBox(height: 4),
            Text(
              entry.mealType!.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _ActionRow(
            icon: Icons.shopping_cart_outlined,
            label: l10n.menuAddToGrocery,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF5C7861),
            onTap: () {
              Navigator.pop(context);
              onImportRecipeToList();
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: isSkipped ? Icons.replay_circle_filled : Icons.do_not_disturb_on,
            label: isSkipped ? l10n.unskipMealAction : l10n.skipMealAction,
            iconBgColor: isSkipped ? const Color(0xFFE8F0E8) : const Color(0xFFFFF0F0),
            iconColor: isSkipped ? const Color(0xFF5C7861) : const Color(0xFFE57373),
            onTap: () {
              Navigator.pop(context);
              onToggleSkipped();
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.calendar_month_outlined,
            label: l10n.changeMealDateAction,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF5C7861),
            onTap: () {
              Navigator.pop(context);
              onChangeDate();
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.favorite_border,
            label: l10n.swapFavoriteAction,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF5C7861),
            onTap: () {
              Navigator.pop(context);
              onSwapRecipe();
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.refresh,
            label: l10n.regenerateRecipeAction,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF5C7861),
            onTap: () {
              Navigator.pop(context);
              onRegenerateEntry();
            },
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.deleteAction,
            iconBgColor: const Color(0xFFE8F0E8),
            iconColor: const Color(0xFF5C7861),
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onDeleteEntry();
            },
          ),
        ],
      ),
    );
  }

  bool _isSkippedStatus(String? status) {
    if (status == null) return false;
    final value = status.trim().toLowerCase();
    return value == 'skipped' || value == 'skiped';
  }
}
