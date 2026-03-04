class GroceryList {
  final int id;
  final String name;
  final int? mealPlanId;
  final DateTime createdAt;

  const GroceryList({
    required this.id,
    required this.name,
    this.mealPlanId,
    required this.createdAt,
  });
}

class GroceryListItem {
  final int id;
  final String ingredientName;
  final double quantity;
  final String unit;
  final bool checked;
  final bool isCoveredByPantry;

  const GroceryListItem({
    required this.id,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.checked,
    required this.isCoveredByPantry,
  });

  GroceryListItem copyWith({
    int? id,
    String? ingredientName,
    double? quantity,
    String? unit,
    bool? checked,
    bool? isCoveredByPantry,
  }) {
    return GroceryListItem(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      checked: checked ?? this.checked,
      isCoveredByPantry: isCoveredByPantry ?? this.isCoveredByPantry,
    );
  }
}

class GroceryListDetail {
  final int id;
  final String name;
  final int? mealPlanId;
  final DateTime createdAt;
  final List<GroceryListItem> items;

  const GroceryListDetail({
    required this.id,
    required this.name,
    this.mealPlanId,
    required this.createdAt,
    required this.items,
  });

  GroceryListDetail copyWith({List<GroceryListItem>? items}) {
    return GroceryListDetail(
      id: id,
      name: name,
      mealPlanId: mealPlanId,
      createdAt: createdAt,
      items: items ?? this.items,
    );
  }
}
