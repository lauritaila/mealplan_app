import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';

class HeroConsistencyRing extends StatelessWidget {
  final double consistencyScore;

  const HeroConsistencyRing({required this.consistencyScore, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final clampedScore = consistencyScore.clamp(0.0, 100.0) / 100.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: clampedScore,
                strokeWidth: 16,
                backgroundColor: customColors.consistencyRingBackground,
                valueColor: AlwaysStoppedAnimation<Color>(
                  customColors.consistencyRingActive!,
                ),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(clampedScore * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: customColors.textDarkBlue,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      'CONSISTENCY',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
