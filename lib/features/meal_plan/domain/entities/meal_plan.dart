class MealPlanResponse {
  final MealPlan plan;
  final MealPlanMeta meta;

  const MealPlanResponse({required this.plan, required this.meta});
}

class MealPlan {
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyMeals> dailyMeals;

  const MealPlan({
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.dailyMeals,
  });
}

class DailyMeals {
  final DateTime date;
  final List<MealEntry> meals;

  const DailyMeals({required this.date, required this.meals});
}

class MealEntry {
  final String mealType;
  final Recipe recipe;

  const MealEntry({required this.mealType, required this.recipe});
}

class Recipe {
  final String name;
  final String description;
  final String instructions;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final List<Ingredient> ingredients;

  const Recipe({
    required this.name,
    required this.description,
    required this.instructions,
    required this.ingredients,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
  });
}

class Ingredient {
  final String name;
  final double quantity;
  final String unit;
  final String category;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
  });
}

class MealPlanMeta {
  final String userId;
  final bool preferencesFound;
  final int recipesProvided;
  final String subscription;
  final String subscriptionPlan;

  const MealPlanMeta({
    required this.userId,
    required this.preferencesFound,
    required this.recipesProvided,
    required this.subscription,
    required this.subscriptionPlan,
  });
}
