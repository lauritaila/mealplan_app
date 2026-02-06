class MealPlanGenerationStatus {
  final bool canGenerate;
  final String? reason;
  final int remaining;

  const MealPlanGenerationStatus({
    required this.canGenerate,
    required this.remaining,
    this.reason,
  });
}
