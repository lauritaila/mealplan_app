import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_entries_provider.g.dart';

@riverpod
Future<List<DayMealEntry>> mealPlanEntries(Ref ref, int planId) async {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getMealPlanEntries(planId);
}
