import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class CookingTimerCard extends StatefulWidget {
  final int seconds;

  const CookingTimerCard({super.key, required this.seconds});

  @override
  State<CookingTimerCard> createState() => _CookingTimerCardState();
}

class _CookingTimerCardState extends State<CookingTimerCard> {
  Timer? _timer;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  @override
  void didUpdateWidget(covariant CookingTimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _remaining = widget.seconds;
      _timer?.cancel();
      _running = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_remaining <= 0) return;
    if (_running) {
      _timer?.cancel();
      setState(() {
        _running = false;
      });
      return;
    }

    setState(() {
      _running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      } else {
        setState(() {
          _remaining -= 1;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remaining = widget.seconds;
      _running = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr : $secStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 0,
      color: customColors.chartTabBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              l10n.timerLabel,
              style: textTheme.labelSmall?.copyWith(
                color: customColors.darkSage,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: customColors.textDarkBlue, size: 32),
                const SizedBox(width: 12),
                Text(
                  _formatTime(_remaining),
                  style: textTheme.displayMedium?.copyWith(
                    color: customColors.textDarkBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? l10n.pauseTimer : l10n.startTimer),
                  style: FilledButton.styleFrom(
                    backgroundColor: customColors.darkSage,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: customColors.slateGrey,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
