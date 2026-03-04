import 'package:flutter/material.dart';

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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weeklyAveragesTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!hideNutritionValues)
              _MacroCard(
                label: l10n.metricCalories,
                value: '${weeklyAverage.calories.toStringAsFixed(0)} ${l10n.metricKcal}',
                color: Colors.orange.shade300,
                icon: Icons.local_fire_department,
              ),
            _MacroCard(
              label: l10n.metricProtein,
              value: '${weeklyAverage.protein.toStringAsFixed(0)} g',
              color: Colors.red.shade300,
              icon: Icons.fitness_center,
            ),
            if (!hideNutritionValues) ...[
              _MacroCard(
                label: l10n.metricCarbs,
                value: '${weeklyAverage.carbs.toStringAsFixed(0)} g',
                color: Colors.amber.shade300,
                icon: Icons.grass,
              ),
              _MacroCard(
                label: l10n.metricFat,
                value: '${weeklyAverage.fats.toStringAsFixed(0)} g',
                color: Colors.blue.shade300,
                icon: Icons.water_drop,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
