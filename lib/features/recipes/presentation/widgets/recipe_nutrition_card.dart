import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipeNutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;

  const RecipeNutritionCard({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: labelColor ?? customColors.darkSage,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: customColors.textDarkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
