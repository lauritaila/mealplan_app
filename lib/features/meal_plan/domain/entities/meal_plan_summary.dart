class MealPlanSummary {
  final int id;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final bool generatedByAi;
  final DateTime createdAt;

  const MealPlanSummary({
    required this.id,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.generatedByAi,
    required this.createdAt,
  });
}
