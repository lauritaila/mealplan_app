class RecipeListItem {
  final int id;
  final String name;
  final bool isFavorite;
  final List<String> categories;
  final double? calories;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;

  const RecipeListItem({
    required this.id,
    required this.name,
    required this.isFavorite,
    required this.categories,
    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
  });
}
