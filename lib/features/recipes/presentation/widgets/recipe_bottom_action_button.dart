import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipeBottomActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RecipeBottomActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: customColors.darkSage, size: 28),
      ),
    );
  }
}
