import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final List<String> categories;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final bool hideNutritionValues;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onAddToGroceryList;

  const RecipeCard({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.categories,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
    this.hideNutritionValues = false,
    required this.onTap,
    required this.onFavoriteTap,
    this.onAddToGroceryList,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final showNutrition = !hideNutritionValues;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Keeping subtle shadow for depth
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Tags & Action Icons
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.take(2).map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: customColors.chartTabBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: customColors.darkSage,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? customColors.darkSage : customColors.slateGrey?.withValues(alpha: 0.3),
                    ),
                    onPressed: onFavoriteTap,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (onAddToGroceryList != null)
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: customColors.slateGrey?.withValues(alpha: 0.3)),
                      onPressed: onAddToGroceryList,
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.menuAddToGrocery,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Recipe Name
              Text(
                name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Nutrition Row
              if (showNutrition)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NutritionItem(
                      icon: Icons.egg_rounded,
                      value: '${proteinGrams?.toInt() ?? 0}G',
                    ),
                    _NutritionItem(
                      icon: Icons.opacity_rounded,
                      value: '${fatsGrams?.toInt() ?? 0}G',
                    ),
                    _NutritionItem(
                      icon: Icons.grain_rounded,
                      value: '${carbsGrams?.toInt() ?? 0}G',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${calories?.toInt() ?? 0}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: customColors.textDarkBlue,
                          ),
                        ),
                        Text(
                          l10n.kcalLabel.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: customColors.slateGrey?.withValues(alpha: 0.5),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _NutritionItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Icon(icon, color: customColors.darkSage, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.slateGrey?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
