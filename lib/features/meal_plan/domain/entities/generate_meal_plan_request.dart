class GenerateMealPlanRequest {
  final int numberOfDays;
  final List<String> mealTypes;
  final int? quantityOfPeople;
  final String? startDate; // YYYY-MM-DD
  final String? description;
  final bool? usePantry;

  GenerateMealPlanRequest({
    required this.numberOfDays,
    required this.mealTypes,
    this.quantityOfPeople,
    this.startDate,
    this.description,
    this.usePantry,
  });

  Map<String, dynamic> toJson() {
    return {
      'numberOfDays': numberOfDays,
      'mealTypes': mealTypes,
      if (quantityOfPeople != null) 'quantityOfPeople': quantityOfPeople,
      if (startDate != null) 'startDate': startDate,
      if (description != null) 'description': description,
      if (usePantry != null) 'usePantry': usePantry,
    };
  }
}
