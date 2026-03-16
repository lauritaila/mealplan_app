class CanGenerateMealPlanResponse {
  final bool canGenerate;
  final String? reason;
  final int mealPlanGenerateLimit;
  final int mealPlanGenerateRemaining;
  final int substituteLimit;
  final int substituteRemaining;
  final int regenerateRecipeLimit;
  final int regenerateRecipeRemaining;
  final int recipeAssistantLimit;
  final int recipeAssistantRemaining;
  final int mealPlanAssistantLimit;
  final int mealPlanAssistantRemaining;

  const CanGenerateMealPlanResponse({
    required this.canGenerate,
    this.reason,
    required this.mealPlanGenerateLimit,
    required this.mealPlanGenerateRemaining,
    required this.substituteLimit,
    required this.substituteRemaining,
    required this.regenerateRecipeLimit,
    required this.regenerateRecipeRemaining,
    required this.recipeAssistantLimit,
    required this.recipeAssistantRemaining,
    required this.mealPlanAssistantLimit,
    required this.mealPlanAssistantRemaining,
  });

  factory CanGenerateMealPlanResponse.fromJson(Map<String, dynamic> json) {
    // Defensively parse canGenerate with a safe default
    final canGenerate = json['canGenerate'] is bool 
        ? json['canGenerate'] as bool 
        : false;

    return CanGenerateMealPlanResponse(
      canGenerate: canGenerate,
      reason: json['reason'] as String?,
      mealPlanGenerateLimit: json['mealPlanGenerateLimit'] as int? ?? 0,
      mealPlanGenerateRemaining: json['mealPlanGenerateRemaining'] as int? ?? 0,
      substituteLimit: json['substituteLimit'] as int? ?? 0,
      substituteRemaining: json['substituteRemaining'] as int? ?? 0,
      regenerateRecipeLimit: json['regenerateRecipeLimit'] as int? ?? 0,
      regenerateRecipeRemaining:
          json['regenerateRecipeRemaining'] as int? ?? 0,
      recipeAssistantLimit: json['recipeAssistantLimit'] as int? ?? 0,
      recipeAssistantRemaining: json['recipeAssistantRemaining'] as int? ?? 0,
      mealPlanAssistantLimit: json['mealPlanAssistantLimit'] as int? ?? 0,
      mealPlanAssistantRemaining:
          json['mealPlanAssistantRemaining'] as int? ?? 0,
    );
  }

  /// Returns true if this user has any substitute quota
  bool get canSubstitute => substituteRemaining > 0;

  /// Returns true if this user is on a plan with no substitute access at all
  bool get hasNoSubstituteAccess => substituteLimit == 0;
}
