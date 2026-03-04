import 'package:flutter/material.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showNutrition =
        !hideNutritionValues &&
        (calories != null ||
            proteinGrams != null ||
            carbsGrams != null ||
            fatsGrams != null);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavoriteTap,
                  ),
                ],
              ),
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: categories.map((category) {
                    return Chip(
                      label: Text(category, style: theme.textTheme.bodySmall),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  }).toList(),
                ),
              ],
              if (showNutrition) ...[
                const SizedBox(height: 12),
                NutritionSummaryCard(
                  protein: proteinGrams,
                  fats: fatsGrams,
                  carbs: carbsGrams,
                  calories: calories,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
