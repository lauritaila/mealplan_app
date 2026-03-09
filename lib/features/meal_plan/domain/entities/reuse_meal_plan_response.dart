class ReuseMealPlanResponse {
  final int sourcePlanId;
  final int newPlanId;
  final String newPlanName;
  final DateTime startDate;
  final DateTime endDate;
  final int entriesCloned;

  const ReuseMealPlanResponse({
    required this.sourcePlanId,
    required this.newPlanId,
    required this.newPlanName,
    required this.startDate,
    required this.endDate,
    required this.entriesCloned,
  });
}
