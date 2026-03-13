class IngredientSubstitutesRequest {
  final String ingredientOriginal;
  final double? quantity;
  final String unit;
  final String context;

  const IngredientSubstitutesRequest({
    required this.ingredientOriginal,
    required this.quantity,
    required this.unit,
    required this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'ingredientOriginal': ingredientOriginal,
      if (quantity != null) 'quantity': quantity,
      if (unit.trim().isNotEmpty) 'unit': unit.trim(),
      if (context.trim().isNotEmpty) 'context': context.trim(),
    };
  }
}
