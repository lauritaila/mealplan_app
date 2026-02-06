class NewMealPlanRequest {
  final int numberOfDays;
  final int? quantityOfPeople;
  final String? description;
  final List<String>? mealTypes;

  const NewMealPlanRequest({
    required this.numberOfDays,
    this.quantityOfPeople,
    this.description,
    this.mealTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'numberOfDays': numberOfDays,
      if (quantityOfPeople != null) 'quantityOfPeople': quantityOfPeople,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (mealTypes != null && mealTypes!.isNotEmpty) 'mealTypes': mealTypes,
    };
  }
}
