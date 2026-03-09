class BulkDeductIngredient {
  final String ingredient;
  final double quantity;
  final String unit;

  const BulkDeductIngredient({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });
}

class BulkDeductResult {
  final List<BulkDeductIngredient> deducted;
  final List<BulkDeductIngredient> missing;

  const BulkDeductResult({required this.deducted, required this.missing});
}
