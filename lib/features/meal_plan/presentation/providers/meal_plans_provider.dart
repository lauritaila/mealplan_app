import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plans_provider.g.dart';

@riverpod
Future<List<MealPlanSummary>> mealPlans(Ref ref) async {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getMealPlans();
}
