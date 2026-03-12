import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/meal_plan/domain/entities/day_meal_entry.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class TodayMealCard extends ConsumerWidget {
  final DayMealEntry entry;
  final int totalEntries;
  final DateTime selectedDate;
  final bool hideNutritionValues;

  const TodayMealCard({
    super.key,
    required this.entry,
    required this.totalEntries,
    required this.selectedDate,
    required this.hideNutritionValues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    final isCompleted = entry.status == 'completed';
    final isSkipped = entry.status?.toLowerCase() == 'skipped' || 
                      entry.status?.toLowerCase() == 'skiped';
    
    final width = totalEntries == 1 ? MediaQuery.of(context).size.width - 48 : MediaQuery.of(context).size.width * 0.85;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: customColors.chartTabBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _getMealIcon(entry.mealType, customColors),
              ),
              const SizedBox(height: 12),
              Text(
                (entry.mealType ?? 'MEAL').toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: customColors.slateGrey?.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isSkipped ? customColors.slateGrey : customColors.textDarkBlue,
                  decoration: isSkipped ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!hideNutritionValues) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniMacroBadge(label: l10n.metricProtein, value: '${entry.proteinGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.metricCarbsShort, value: '${entry.carbsGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.metricFat, value: '${entry.fatsGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.kcalLabel, value: '${entry.calories?.toInt() ?? 0}'),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (entry.recipeId > 0) {
                          context.push('/recipes/${entry.recipeId}?entryId=${entry.entryId}&status=${entry.status}');
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: customColors.chartTabBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        l10n.homeViewRecipeShort,
                        style: TextStyle(color: customColors.textDarkBlue, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (entry.entryId > 0) {
                          _confirmAndToggleSkip(context, ref, l10n, entry, selectedDate);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        l10n.homeEatOutAction,
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Checkmark at top right for marking as completed
          if (!isSkipped)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: isCompleted ? null : () => _confirmComplete(context, ref, l10n, entry, selectedDate),
                child: Icon(
                  Icons.check_circle,
                  size: 28,
                  color: isCompleted ? customColors.darkSage : customColors.slateGrey?.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmComplete(BuildContext context, WidgetRef ref, AppLocalizations l10n, DayMealEntry entry, DateTime selectedDate) async {
    if (entry.recipeId <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markCompleteDialogTitle),
        content: Text(l10n.markCompleteQuestion(entry.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(l10n.completeAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .bulkDeduct(
          entry.recipeId,
          entry.servings ?? 1,
          entryId: entry.entryId,
        );
        
    if (!context.mounted) return;
    
    ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
    
    if (result != null) {
      CustomSnackbar.showInfo(
          context,
          result.missing.isEmpty
              ? l10n.mealCompletedSuccess(result.deducted.length)
              : l10n.mealCompletedMissing(result.missing.length),
      );
    }
  }

  Widget _getMealIcon(String? type, AppCustomColors customColors) {
    final lower = type?.toLowerCase() ?? '';
    if (lower.contains('breakfast')) return Icon(Icons.bakery_dining_outlined, color: customColors.darkSage);
    if (lower.contains('lunch')) return Icon(Icons.soup_kitchen_outlined, color: customColors.darkSage);
    if (lower.contains('dinner')) return Icon(Icons.eco_outlined, color: customColors.darkSage);
    if (lower.contains('snack')) return Icon(Icons.fastfood_outlined, color: customColors.darkSage);
    return Icon(Icons.restaurant_outlined, color: customColors.darkSage);
  }

  Future<void> _confirmAndToggleSkip(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DayMealEntry entry,
    DateTime date,
  ) async {
    final isSkipped = entry.status?.toLowerCase() == 'skipped' || 
                      entry.status?.toLowerCase() == 'skiped';
    
    bool confirm = true;
    if (!isSkipped) {
      confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.homeSkipMealQuestion),
          content: Text(l10n.homeSkipMealDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.homeConfirmAction),
            ),
          ],
        ),
      ) ?? false;
    }

    if (confirm != true || !context.mounted) return;
    await ref.read(dayMealEntryStatusUpdateProvider.notifier).toggleSkipped(entry, date);
  }
}

class _MiniMacroBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMacroBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: customColors.darkSage,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
