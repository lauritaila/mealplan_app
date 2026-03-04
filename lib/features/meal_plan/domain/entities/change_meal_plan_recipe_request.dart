class ChangeMealPlanRecipeRequest {
  final String? description;
  final int? quantityOfPeople;
  final List<String>? mealTypes;
  final int? maxTotalTimeMinutes;
  final bool? usePantry;

  const ChangeMealPlanRecipeRequest({
    this.description,
    this.quantityOfPeople,
    this.mealTypes,
    this.maxTotalTimeMinutes,
    this.usePantry,
  });

  Map<String, dynamic> toJson() {
    return {
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (quantityOfPeople != null) 'quantityOfPeople': quantityOfPeople,
      if (mealTypes != null && mealTypes!.isNotEmpty) 'mealTypes': mealTypes,
      if (maxTotalTimeMinutes != null)
        'maxTotalTimeMinutes': maxTotalTimeMinutes,
      if (usePantry != null) 'usePantry': usePantry,
    };
  }
}
