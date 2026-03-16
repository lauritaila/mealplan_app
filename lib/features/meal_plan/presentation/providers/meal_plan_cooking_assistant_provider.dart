import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

// part 'meal_plan_cooking_assistant_provider.g.dart';

final mealPlanCookingAssistantProvider = FutureProvider.family<MealPlanCookingAssistantResponseDto, int>((ref, planId) {
  final repository = ref.watch(mealPlanRepositoryProvider);
  return repository.getMealPlanCookingAssistant(planId);
});
