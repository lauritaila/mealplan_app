import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDestructive 
                    ? theme.colorScheme.error 
                    : customColors.textDarkBlue,
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
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final isSkipped = _isSkippedStatus(entry.status);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: customColors.slateGrey?.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            entry.name,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
          if (entry.mealType != null) ...[
            const SizedBox(height: 8),
            Text(
              entry.mealType!.toUpperCase(),
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: customColors.darkSage,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _ActionRow(
            icon: Icons.shopping_cart_outlined,
            label: l10n.menuAddToGrocery,
            iconBgColor: customColors.chartTabBackground!,
            iconColor: customColors.darkSage!,
            onTap: () {
              Navigator.pop(context);
              onImportRecipeToList();
            },
          ),
          _ActionRow(
            icon: isSkipped ? Icons.replay_circle_filled : Icons.do_not_disturb_on,
            label: isSkipped ? l10n.unskipMealAction : l10n.skipMealAction,
            iconBgColor: isSkipped 
                ? customColors.chartTabBackground! 
                : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            iconColor: isSkipped 
                ? customColors.darkSage! 
                : theme.colorScheme.error,
            onTap: () {
              Navigator.pop(context);
              onToggleSkipped();
            },
          ),
          _ActionRow(
            icon: Icons.calendar_month_outlined,
            label: l10n.changeMealDateAction,
            iconBgColor: customColors.chartTabBackground!,
            iconColor: customColors.darkSage!,
            onTap: () {
              Navigator.pop(context);
              onChangeDate();
            },
          ),
          _ActionRow(
            icon: Icons.favorite_border,
            label: l10n.swapFavoriteAction,
            iconBgColor: customColors.chartTabBackground!,
            iconColor: customColors.darkSage!,
            onTap: () {
              Navigator.pop(context);
              onSwapRecipe();
            },
          ),
          _ActionRow(
            icon: Icons.refresh,
            label: l10n.regenerateRecipeAction,
            iconBgColor: customColors.chartTabBackground!,
            iconColor: customColors.darkSage!,
            onTap: () {
              Navigator.pop(context);
              onRegenerateEntry();
            },
          ),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.deleteAction,
            iconBgColor: customColors.chartTabBackground!,
            iconColor: customColors.darkSage!,
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
