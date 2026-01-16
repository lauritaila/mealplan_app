class DayMealEntry {
  final String? mealType;
  final String name;
  final String description;
  final String instructions;
  final List<DayMealIngredient> ingredients;
  final int? servings;
  final double? calories;
  final double? fatsGrams;
  final double? carbsGrams;
  final double? proteinGrams;

  const DayMealEntry({
    this.mealType,
    required this.name,
    required this.description,
    required this.instructions,
    required this.ingredients,
    this.servings,
    this.calories,
    this.fatsGrams,
    this.carbsGrams,
    this.proteinGrams,
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
