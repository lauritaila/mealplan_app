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
          entryId: _toInt(mealMap['id'] ?? mealMap['entry_id']) ?? 0,
          mealType: (mealMap['meal_type'] ?? '') as String,
          name: (recipeMap['name'] ?? mealMap['name'] ?? '') as String,
          description: recipeMap['description'] as String?,
          servings: _toInt(
            mealMap['servings_planned'] ??
                recipeMap['servings'] ??
                mealMap['servings'],
          ),
          calories: _toDouble(recipeMap['calories'] ?? mealMap['calories']),
          proteinGrams: _toDouble(
            recipeMap['protein_grams'] ?? recipeMap['proteinGrams'],
          ),
          carbsGrams: _toDouble(
            recipeMap['carbs_grams'] ?? recipeMap['carbsGrams'],
          ),
          fatsGrams: _toDouble(
            recipeMap['fats_grams'] ?? recipeMap['fatsGrams'],
          ),
          categories: _toStringList(recipeMap['categories']),
          recipe: Recipe(
            id: _toInt(recipeMap['id']),
            name: (recipeMap['name'] ?? '') as String,
            description: (recipeMap['description'] ?? '') as String,
            instructions: (recipeMap['instructions'] ?? '') as String,
            isFavorite: (recipeMap['is_favorite'] ?? false) as bool,
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
      id: _toInt(planMap['id']) ?? 0,
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
          _toInt(metaMap['recipesProvided'] ?? metaMap['recipes_provided']) ??
          0,
      subscription: (metaMap['subscription'] ?? '') as String,
      subscriptionPlan:
          (metaMap['subscriptionPlan'] ?? metaMap['subscription_plan'] ?? '')
              as String,
      persistenceStatus:
          (metaMap['persistenceStatus'] ?? metaMap['persistence_status'] ?? '')
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
                        'entry_id': meal.entryId,
                        'meal_type': meal.mealType,
                        'recipe': {
                          'id': meal.recipe.id,
                          'name': meal.recipe.name,
                          'description': meal.recipe.description,
                          'instructions': meal.recipe.instructions,
                          'prep_time_minutes': meal.recipe.prepTimeMinutes,
                          'is_favorite': meal.recipe.isFavorite,
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
        'persistenceStatus': response.meta.persistenceStatus,
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

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
