import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class GamificationAchievements extends StatelessWidget {
  const GamificationAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // For now, this uses mocked data as we don't have the API endpoint for it yet.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.achievementsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _AchievementTile(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: l10n.achievementStreakTitle,
          description: l10n.achievementStreakDesc,
        ),
        const SizedBox(height: 12),
        _AchievementTile(
          icon: Icons.eco,
          iconColor: Colors.green,
          title: l10n.achievementWasteTitle,
          description: l10n.achievementWasteDesc,
        ),
        const SizedBox(height: 12),
        _AchievementTile(
          icon: Icons.restaurant_menu,
          iconColor: Colors.purple,
          title: l10n.achievementVarietyTitle,
          description: l10n.achievementVarietyDesc,
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _AchievementTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
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
