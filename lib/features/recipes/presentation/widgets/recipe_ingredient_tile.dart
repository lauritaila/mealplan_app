import 'package:flutter/material.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/recipes/domain/entities/recipe_ingredient.dart';

class RecipeIngredientTile extends StatelessWidget {
  final RecipeIngredient ingredient;
  final VoidCallback onSubstitute;

  const RecipeIngredientTile({
    super.key,
    required this.ingredient,
    required this.onSubstitute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: customColors.darkSage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: customColors.textDarkBlue,
              ),
            ),
          ),
          Text(
            '${ingredient.quantity?.toInt() ?? ''} ${ingredient.unit}',
            style: textTheme.bodyMedium?.copyWith(
              color: customColors.darkSage,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSubstitute,
            child: Icon(Icons.sync, size: 20, color: customColors.darkSage),
          ),
        ],
      ),
    );
  }
}
