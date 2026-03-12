import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class HomeWeekProgressIndicator extends StatelessWidget {
  final AsyncValue nutritionAsync;
  const HomeWeekProgressIndicator({super.key, required this.nutritionAsync});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.homeWeekLabel,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: customColors.slateGrey?.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          nutritionAsync.when(
            data: (summary) {
              final score = summary.weeklyAverage.consistencyScore;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 5,
                      backgroundColor: customColors.chartTabBackground,
                      color: customColors.darkSage,
                    ),
                  ),
                  Text(
                    '${score.toInt()}%',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: customColors.textDarkBlue,
                    ),
                  ),
                ],
              );
            },
            loading: () => SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(strokeWidth: 3, color: customColors.darkSage),
            ),
            error: (error, stack) => Icon(Icons.error_outline, color: customColors.slateGrey),
          ),
        ],
      ),
    );
  }
}
