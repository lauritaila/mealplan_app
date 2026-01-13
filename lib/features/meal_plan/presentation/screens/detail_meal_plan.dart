import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';

class DetailMealPlanScreen extends ConsumerWidget {
  final MealPlanResponse? generatedPlan;

  const DetailMealPlanScreen({super.key, this.generatedPlan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = generatedPlan?.plan;

    return Scaffold(
      appBar: AppBar(title: const Text('Aprobar plan')),
      body: generatedPlan == null
          ? const Center(child: Text('No plan data received.'))
          : Stack(
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label:
                              'Recetas: ${generatedPlan!.meta.recipesProvided}',
                        ),
                        _Chip(
                          label:
                              'Suscripcion: ${generatedPlan!.meta.subscriptionPlan}',
                        ),
                        _Chip(
                          label:
                              'Preferencias cargadas: ${generatedPlan!.meta.preferencesFound ? 'si' : 'no'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...plan.dailyMeals
                        .map((day) => _DayCard(day: day))
                        .toList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: generatedPlan == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Listo'),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                '${day.meals.length} comidas',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.meals.map((meal) => _MealTile(meal: meal)).toList(),
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
                meal.mealType.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (recipe.calories != null)
                Text(
                  '${recipe.calories!.toStringAsFixed(0)} kcal',
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
                _Chip(label: 'Raciones: ${recipe.servings}'),
              if (recipe.prepTimeMinutes != null)
                _Chip(label: 'Prep: ${recipe.prepTimeMinutes} min'),
              if (recipe.cookTimeMinutes != null)
                _Chip(label: 'Coccion: ${recipe.cookTimeMinutes} min'),
              if (recipe.proteinGrams != null)
                _Chip(
                  label:
                      'Proteina: ${recipe.proteinGrams!.toStringAsFixed(1)} g',
                ),
              if (recipe.carbsGrams != null)
                _Chip(
                  label: 'Carbs: ${recipe.carbsGrams!.toStringAsFixed(1)} g',
                ),
              if (recipe.fatsGrams != null)
                _Chip(
                  label: 'Grasas: ${recipe.fatsGrams!.toStringAsFixed(1)} g',
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ingredientes',
            style: TextStyle(fontWeight: FontWeight.w700),
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

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
