class NewMealPlanRequest {
  final int numberOfDays;
  final int? quantityOfPeople;
  final String? description;
  final List<String>? mealTypes;
  final String? startDate; // YYYY-MM-DD
  final bool? usePantry;

  const NewMealPlanRequest({
    required this.numberOfDays,
    this.quantityOfPeople,
    this.description,
    this.mealTypes,
    this.startDate,
    this.usePantry,
  });

  Map<String, dynamic> toJson() {
    return {
      'numberOfDays': numberOfDays,
      if (quantityOfPeople != null) 'quantityOfPeople': quantityOfPeople,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (mealTypes != null && mealTypes!.isNotEmpty) 'mealTypes': mealTypes,
      if (startDate != null && startDate!.isNotEmpty) 'start_date': startDate,
      if (usePantry != null) 'usePantry': usePantry,
    };
  }
}
