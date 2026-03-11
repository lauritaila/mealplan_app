import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final showNutrition = !hideNutritionValues;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F4F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
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
                            color: const Color(0xFFF2F7F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF6A8773),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? const Color(0xFF6A8773) : const Color(0xFFBCC6C0),
                    ),
                    onPressed: onFavoriteTap,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (onAddToGroceryList != null)
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFBCC6C0)),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1E1B),
                  height: 1.3,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1E1B),
                          ),
                        ),
                        const Text(
                          'KCAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFBCC6C0),
                            letterSpacing: 0.5,
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
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6A8773), size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFBCC6C0),
          ),
        ),
      ],
    );
  }
}
