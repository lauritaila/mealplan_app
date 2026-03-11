import 'package:flutter/material.dart';

class HeroConsistencyRing extends StatelessWidget {
  final double consistencyScore;

  const HeroConsistencyRing({required this.consistencyScore, super.key});

  @override
  Widget build(BuildContext context) {
    final clampedScore = consistencyScore.clamp(0.0, 100.0) / 100.0;
    final color = const Color(0xFF7BA082); // Muted green from screenshot

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
                backgroundColor: const Color(0xFFE8F0E8),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(clampedScore * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001B3A),
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      'CONSISTENCY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey.shade600,
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
