class MealPlanCookingAssistantResponseDto {
  final int planId;
  final String planName;
  final int totalRecipes;
  final int totalEstimatedMinutes;
  final List<CookingScheduleDto> schedule;

  MealPlanCookingAssistantResponseDto({
    required this.planId,
    required this.planName,
    required this.totalRecipes,
    required this.totalEstimatedMinutes,
    required this.schedule,
  });

  factory MealPlanCookingAssistantResponseDto.fromJson(Map<String, dynamic> json) {
    return MealPlanCookingAssistantResponseDto(
      planId: json['plan_id'] as int,
      planName: json['plan_name'] as String,
      totalRecipes: json['total_recipes'] as int,
      totalEstimatedMinutes: json['total_estimated_minutes'] as int,
      schedule: (json['schedule'] as List<dynamic>)
          .map((e) => CookingScheduleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CookingScheduleDto {
  final String mealDate;
  final String mealType;
  final int recipeId;
  final String recipeName;
  final int estimatedTimeMinutes;
  final List<CookingStepDto> steps;

  CookingScheduleDto({
    required this.mealDate,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.estimatedTimeMinutes,
    required this.steps,
  });

  factory CookingScheduleDto.fromJson(Map<String, dynamic> json) {
    return CookingScheduleDto(
      mealDate: json['meal_date'] as String,
      mealType: json['meal_type'] as String,
      recipeId: json['recipe_id'] as int,
      recipeName: json['recipe_name'] as String,
      estimatedTimeMinutes: json['estimated_time_minutes'] as int,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => CookingStepDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CookingStepDto {
  final int stepNumber;
  final String instruction;
  final List<CookingIngredientUsedDto> ingredientsUsed;
  final List<String> toolsNeeded;
  final int estimatedTimeSeconds;
  final bool isTimerNecessary;

  CookingStepDto({
    required this.stepNumber,
    required this.instruction,
    required this.ingredientsUsed,
    required this.toolsNeeded,
    required this.estimatedTimeSeconds,
    required this.isTimerNecessary,
  });

  factory CookingStepDto.fromJson(Map<String, dynamic> json) {
    return CookingStepDto(
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      ingredientsUsed: (json['ingredients_used'] as List<dynamic>?)
              ?.map((e) => CookingIngredientUsedDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      toolsNeeded: (json['tools_needed'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      estimatedTimeSeconds: json['estimated_time_seconds'] as int? ?? 0,
      isTimerNecessary: json['is_timer_necessary'] as bool? ?? false,
    );
  }
}

class CookingIngredientUsedDto {
  final String name;
  final num quantity;
  final String unit;

  CookingIngredientUsedDto({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory CookingIngredientUsedDto.fromJson(Map<String, dynamic> json) {
    return CookingIngredientUsedDto(
      name: json['name'] as String,
      quantity: json['quantity'] as num,
      unit: json['unit'] as String,
    );
  }
}
