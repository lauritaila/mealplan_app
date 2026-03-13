import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class CookingInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const CookingInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: customColors.darkSage, size: 24),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: customColors.textDarkBlue,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: customColors.slateGrey,
            ),
          ),
          trailing: onTap != null 
            ? Icon(Icons.swap_horiz, color: customColors.darkSage, size: 20)
            : null,
        ),
      ),
    );
  }
}
