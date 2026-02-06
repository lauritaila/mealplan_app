import 'package:meal_plan_app/features/meal_plan/domain/entities/meal_plan.dart';

class MealPlanResponseMapper {
  static MealPlanResponse fromMap(Map<String, dynamic> data) {
    final planMap = Map<String, dynamic>.from(data['plan'] ?? {});
    final metaMap = Map<String, dynamic>.from(data['meta'] ?? {});

    final dailyMeals = (planMap['daily_meals'] as List? ?? []).map((day) {
      final dayMap = Map<String, dynamic>.from(day as Map);
      final meals = (dayMap['meals'] as List? ?? []).map((meal) {
        final mealMap = Map<String, dynamic>.from(meal as Map);
        final recipeMap = Map<String, dynamic>.from(mealMap['recipe'] ?? {});
        return MealEntry(
          mealType: (mealMap['meal_type'] ?? '') as String,
          recipe: Recipe(
            name: (recipeMap['name'] ?? '') as String,
            description: (recipeMap['description'] ?? '') as String,
            instructions: (recipeMap['instructions'] ?? '') as String,
            prepTimeMinutes: _toInt(recipeMap['prep_time_minutes']),
            cookTimeMinutes: _toInt(recipeMap['cook_time_minutes']),
            servings: _toInt(recipeMap['servings']),
            calories: _toDouble(recipeMap['calories']),
            proteinGrams: _toDouble(recipeMap['protein_grams']),
            carbsGrams: _toDouble(recipeMap['carbs_grams']),
            fatsGrams: _toDouble(recipeMap['fats_grams']),
            ingredients: (recipeMap['ingredients'] as List? ?? []).map((
              ingredient,
            ) {
              final ingredientMap = Map<String, dynamic>.from(
                ingredient as Map,
              );
              return Ingredient(
                name: (ingredientMap['name'] ?? '') as String,
                quantity: _toDouble(ingredientMap['quantity']) ?? 0,
                unit: (ingredientMap['unit'] ?? '') as String,
                category: (ingredientMap['category'] ?? '') as String,
              );
            }).toList(),
          ),
        );
      }).toList();

      return DailyMeals(date: _parseDate(dayMap['date']), meals: meals);
    }).toList();

    final plan = MealPlan(
      planName: (planMap['plan_name'] ?? '') as String,
      startDate: _parseDate(planMap['start_date']),
      endDate: _parseDate(planMap['end_date']),
      dailyMeals: dailyMeals,
    );

    final meta = MealPlanMeta(
      userId: (metaMap['userId'] ?? metaMap['user_id'] ?? '') as String,
      preferencesFound:
          (metaMap['preferencesFound'] ?? metaMap['preferences_found'] ?? false)
              as bool,
      recipesProvided:
          (metaMap['recipesProvided'] ?? metaMap['recipes_provided'] ?? 0)
              as int,
      subscription: (metaMap['subscription'] ?? '') as String,
      subscriptionPlan:
          (metaMap['subscriptionPlan'] ?? metaMap['subscription_plan'] ?? '')
              as String,
    );

    return MealPlanResponse(plan: plan, meta: meta);
  }

  static Map<String, dynamic> toMap(MealPlanResponse response) {
    return {
      'plan': {
        'plan_name': response.plan.planName,
        'start_date': _dateOnly(response.plan.startDate),
        'end_date': _dateOnly(response.plan.endDate),
        'daily_meals': response.plan.dailyMeals
            .map(
              (day) => {
                'date': _dateOnly(day.date),
                'meals': day.meals
                    .map(
                      (meal) => {
                        'meal_type': meal.mealType,
                        'recipe': {
                          'name': meal.recipe.name,
                          'description': meal.recipe.description,
                          'instructions': meal.recipe.instructions,
                          'prep_time_minutes': meal.recipe.prepTimeMinutes,
                          'cook_time_minutes': meal.recipe.cookTimeMinutes,
                          'servings': meal.recipe.servings,
                          'calories': meal.recipe.calories,
                          'protein_grams': meal.recipe.proteinGrams,
                          'carbs_grams': meal.recipe.carbsGrams,
                          'fats_grams': meal.recipe.fatsGrams,
                          'ingredients': meal.recipe.ingredients
                              .map(
                                (ingredient) => {
                                  'name': ingredient.name,
                                  'quantity': ingredient.quantity,
                                  'unit': ingredient.unit,
                                  'category': ingredient.category,
                                },
                              )
                              .toList(),
                        },
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      },
      'meta': {
        'userId': response.meta.userId,
        'preferencesFound': response.meta.preferencesFound,
        'recipesProvided': response.meta.recipesProvided,
        'subscription': response.meta.subscription,
        'subscriptionPlan': response.meta.subscriptionPlan,
      },
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      if (value is DateTime) return value;
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _dateOnly(DateTime date) =>
      date.toIso8601String().split('T').first;
}
