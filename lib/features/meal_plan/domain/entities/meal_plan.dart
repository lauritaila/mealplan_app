class MealPlanResponse {
  final MealPlan plan;
  final MealPlanMeta meta;

  const MealPlanResponse({required this.plan, required this.meta});
}

class MealPlan {
  final int id;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyMeals> dailyMeals;

  const MealPlan({
    required this.id,
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
  final int entryId;
  final String mealType;
  final String name;
  final String? description;
  final int? servings;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final List<String> categories;
  final String? status;
  final Recipe recipe;

  const MealEntry({
    required this.entryId,
    required this.mealType,
    required this.name,
    required this.recipe,
    this.description,
    this.servings,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
    this.categories = const [],
    this.status,
  });
}

class Recipe {
  final int? id;
  final String name;
  final String description;
  final String instructions;
  final bool isFavorite;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final List<Ingredient> ingredients;

  const Recipe({
    this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.ingredients,
    this.isFavorite = false,
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
  final String persistenceStatus;

  const MealPlanMeta({
    required this.userId,
    required this.preferencesFound,
    required this.recipesProvided,
    required this.subscription,
    required this.subscriptionPlan,
    required this.persistenceStatus,
  });
}
