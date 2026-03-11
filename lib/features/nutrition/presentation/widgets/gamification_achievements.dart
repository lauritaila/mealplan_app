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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001B3A),
          ),
        ),
        const SizedBox(height: 16),
        _AchievementTile(
          icon: Icons.workspace_premium, // Updated to match screenshot
          title: '7 Day Streak', // Mocking for visual match, l10n.achievementStreakTitle
          description: 'Consistent tracking for a full week', // l10n.achievementStreakDesc
        ),
        const SizedBox(height: 12),
        _AchievementTile(
          icon: Icons.restaurant, 
          title: 'Protein Master', // l10n...
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(20), // More rounded corners
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFDCE6DE), // Light green background for icon
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF7BA082), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF001B3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
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
