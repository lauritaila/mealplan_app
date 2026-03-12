import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class CookingStepInstructionCard extends StatelessWidget {
  final String instruction;

  const CookingStepInstructionCard({
    super.key,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    final title = instruction.split('\n').first.trim().replaceFirst(RegExp(r'^\d+[\.\)\s]+'), '');
    final hasDetails = instruction.contains('\n');
    final details = hasDetails ? instruction.substring(instruction.indexOf('\n') + 1).trim() : '';

    return Card(
      elevation: 0,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: customColors.textDarkBlue,
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
            ),
            if (hasDetails) ...[
              const SizedBox(height: 16),
              Text(
                details,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: customColors.slateGrey,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
