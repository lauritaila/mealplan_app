class RecipeIngredient {
  final int? id;
  final String name;
  final double? quantity;
  final String unit;

  const RecipeIngredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });
}
