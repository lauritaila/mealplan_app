import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class CookingAssistantProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;

  const CookingAssistantProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 0) return const SizedBox.shrink();
    
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    final progress = (currentIndex + 1) / totalSteps;
    final percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cookingProgress,
            style: textTheme.labelSmall?.copyWith(
              color: customColors.darkSage?.withValues(alpha: 0.7),
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.stepOfTotal(currentIndex + 1, totalSteps),
                      style: textTheme.headlineSmall?.copyWith(
                        color: customColors.textDarkBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.percentCompleted(percentage),
                style: textTheme.bodyMedium?.copyWith(
                  color: customColors.darkSage,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: customColors.chartTabBackground,
              valueColor: AlwaysStoppedAnimation<Color>(customColors.darkSage!),
            ),
          ),
        ],
      ),
    );
  }
}
