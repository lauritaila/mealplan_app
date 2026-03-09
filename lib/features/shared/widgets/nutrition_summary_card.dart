import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class NutritionSummaryCard extends StatelessWidget {
  final double? protein;
  final double? fats;
  final double? carbs;
  final double? calories;

  const NutritionSummaryCard({
    super.key,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NutritionMetric(
              label: l10n.metricProtein,
              value: _formatDouble(protein, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: l10n.metricFat,
              value: _formatDouble(fats, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: l10n.metricCarbs,
              value: _formatDouble(carbs, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _NutritionMetric(
              label: l10n.metricKcal,
              value: _formatDouble(calories),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionMetric extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

String _formatDouble(double? value, {int decimals = 0, String suffix = ''}) {
  if (value == null) return '--';
  final formatted = value.toStringAsFixed(decimals);
  return suffix.isEmpty ? formatted : '$formatted$suffix';
}
