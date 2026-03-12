import 'package:flutter/material.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class GamificationAchievements extends StatelessWidget {
  const GamificationAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.achievementsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: customColors.textDarkBlue,
          ),
        ),
        const SizedBox(height: 16),
        _AchievementTile(
          icon: Icons.workspace_premium,
          title: '7 Day Streak',
          description: 'Consistent tracking for a full week',
        ),
        const SizedBox(height: 12),
        _AchievementTile(
          icon: Icons.restaurant, 
          title: 'Protein Master',
          description: 'Met protein needs 5 days in a row',
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AchievementTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: customColors.achievementIconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: customColors.achievementIcon, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: customColors.textDarkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
