import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class HeroConsistencyRing extends StatelessWidget {
  final double consistencyScore;

  const HeroConsistencyRing({required this.consistencyScore, super.key});

  @override
  Widget build(BuildContext context) {
    final clampedScore = consistencyScore.clamp(0.0, 100.0) / 100.0;
    final color = _getScoreColor(clampedScore);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.consistencyRingTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: l10n.consistencyRingTooltip,
              textAlign: TextAlign.center,
              triggerMode: TooltipTriggerMode.tap,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              showDuration: const Duration(seconds: 4),
              child: Icon(
                Icons.info_outline,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.consistencyRingSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: clampedScore,
                strokeWidth: 20,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${consistencyScore.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _getMotivationalMessage(consistencyScore, l10n),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getScoreColor(double ratio) {
    if (ratio >= 0.8) return Colors.green.shade400;
    if (ratio >= 0.5) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  String _getMotivationalMessage(double score, AppLocalizations l10n) {
    if (score >= 80) return l10n.consistencyMessageHigh(score.toStringAsFixed(0));
    if (score >= 50) return l10n.consistencyMessageMedium;
    return l10n.consistencyMessageLow;
  }
}
