class DayMealEntry {
  final int entryId;
  final int recipeId;
  final String? mealType;
  final String name;
  final String? status;
  final List<String> categories;
  final String? description;
  final String? instructions;
  final List<DayMealIngredient> ingredients;
  final int? servings;
  final double? calories;
  final double? fatsGrams;
  final double? carbsGrams;
  final double? proteinGrams;
  final DateTime? mealDate;

  const DayMealEntry({
    required this.entryId,
    required this.recipeId,
    this.mealType,
    required this.name,
    this.status,
    this.categories = const [],
    this.description,
    this.instructions,
    this.ingredients = const [],
    this.servings,
    this.calories,
    this.fatsGrams,
    this.carbsGrams,
    this.proteinGrams,
    this.mealDate,
  });
}

class DayMealIngredient {
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;

  const DayMealIngredient({
    required this.name,
    this.quantity,
    this.unit,
    this.category,
  });
}
