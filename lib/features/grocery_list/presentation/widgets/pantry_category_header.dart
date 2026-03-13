import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class PantryCategoryHeader extends StatelessWidget {
  final String label;
  const PantryCategoryHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: customColors.slateGrey?.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
