import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipeInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const RecipeInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Column(
      children: [
        Icon(icon, color: customColors.darkSage, size: 24),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.slateGrey?.withValues(alpha: 0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
      ],
    );
  }
}
