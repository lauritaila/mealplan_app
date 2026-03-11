import 'package:flutter/material.dart';

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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Totals', // Using English as per screenshot, or we could use l10n.weeklyAveragesTitle but screenshot uses English
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001B3A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MacroCard(
                label: 'ENERGY',
                value: weeklyAverage.calories.toStringAsFixed(0),
                unit: 'kcal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroCard(
                label: 'PROTEIN',
                value: weeklyAverage.protein.toStringAsFixed(0),
                unit: 'g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroCard(
                label: 'CARBS',
                value: weeklyAverage.carbs.toStringAsFixed(0),
                unit: 'g',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroCard(
                label: 'FATS',
                value: weeklyAverage.fats.toStringAsFixed(0),
                unit: 'g',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF001B3A),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
