import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/weekly_average.dart';

class WeeklyAveragesCard extends StatelessWidget {
  final WeeklyAverage weeklyAverage;
  final bool hideNutritionValues;

  const WeeklyAveragesCard({
    required this.weeklyAverage,
    required this.hideNutritionValues,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (hideNutritionValues) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dailyTotalsTitle ?? 'Daily Totals', 
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MacroCard(
                label: l10n.metricCalories.toUpperCase(),
                value: weeklyAverage.calories.toStringAsFixed(0),
                unit: l10n.metricKcal.toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroCard(
                label: l10n.metricProtein.toUpperCase(),
                value: weeklyAverage.protein.toStringAsFixed(0),
                unit: 'G',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroCard(
                label: l10n.metricCarbs.toUpperCase(),
                value: weeklyAverage.carbs.toStringAsFixed(0),
                unit: 'G',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroCard(
                label: l10n.metricFat.toUpperCase(),
                value: weeklyAverage.fats.toStringAsFixed(0),
                unit: 'G',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: customColors.slateGrey?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: customColors.slateGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
