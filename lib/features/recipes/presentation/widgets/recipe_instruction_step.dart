import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipeInstructionStep extends StatelessWidget {
  final int index;
  final String text;

  const RecipeInstructionStep({
    super.key,
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: customColors.darkSage,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(
                color: customColors.slateGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
