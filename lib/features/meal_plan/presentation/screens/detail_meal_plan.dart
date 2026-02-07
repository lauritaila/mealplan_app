import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DetailMealPlanScreen extends ConsumerWidget {
  final MealPlanResponse? generatedPlan;

  const DetailMealPlanScreen({super.key, this.generatedPlan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = generatedPlan?.plan;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.approvePlanTitle)),
      body: generatedPlan == null
          ? Center(child: Text(l10n.noPlanDataReceived))
          : SafeArea(
            child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        plan!.planName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      ...plan.dailyMeals
                          .map((day) => _DayCard(day: day)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
          ),
      bottomNavigationBar: generatedPlan == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l10n.done),
              ),
            ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DailyMeals day;

  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(day.date),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.mealsCount(day.meals.length),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.meals.map((meal) => _MealTile(meal: meal)),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final MealEntry meal;

  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    final recipe = meal.recipe;
    final l10n = AppLocalizations.of(context);
    final mealTypeLabel = _mealTypeLabel(l10n, meal.mealType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealTypeLabel.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (recipe.calories != null)
                Text(
                  l10n.caloriesKcal(recipe.calories!.toStringAsFixed(0)),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            recipe.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            recipe.description,
            style: TextStyle(color: Colors.grey.shade800),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (recipe.servings != null)
                _Chip(label: l10n.servingsLabel(recipe.servings.toString())),
              if (recipe.prepTimeMinutes != null)
                _Chip(
                  label: l10n.prepMinutesLabel(
                    recipe.prepTimeMinutes.toString(),
                  ),
                ),
              if (recipe.cookTimeMinutes != null)
                _Chip(
                  label: l10n.cookMinutesLabel(
                    recipe.cookTimeMinutes.toString(),
                  ),
                ),
              if (recipe.proteinGrams != null)
                _Chip(
                  label:
                      l10n.proteinLabel(recipe.proteinGrams!.toStringAsFixed(1)),
                ),
              if (recipe.carbsGrams != null)
                _Chip(
                  label: l10n.carbsLabel(recipe.carbsGrams!.toStringAsFixed(1)),
                ),
              if (recipe.fatsGrams != null)
                _Chip(
                  label: l10n.fatsLabel(recipe.fatsGrams!.toStringAsFixed(1)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.ingredientsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...recipe.ingredients.map(
            (ingredient) => Text(
              '• ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit} (${ingredient.category})',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

String _mealTypeLabel(AppLocalizations l10n, String mealType) {
  switch (mealType.toLowerCase()) {
    case 'breakfast':
    case 'desayuno':
      return l10n.mealTypeBreakfast;
    case 'lunch':
    case 'almuerzo':
      return l10n.mealTypeLunch;
    case 'dinner':
    case 'cena':
      return l10n.mealTypeDinner;
    case 'snack':
    case 'merienda':
      return l10n.mealTypeSnack;
    default:
      return mealType;
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
