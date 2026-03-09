class PantryItem {
  final int id;
  final int? ingredientId;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expiresAt;

  const PantryItem({
    required this.id,
    this.ingredientId,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.category,
    this.expiresAt,
  });

  PantryItem copyWith({
    double? quantity,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) {
    return PantryItem(
      id: id,
      ingredientId: ingredientId,
      ingredientName: ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit,
      category: category,
      expiresAt: clearExpiry ? null : expiresAt ?? this.expiresAt,
    );
  }
}
