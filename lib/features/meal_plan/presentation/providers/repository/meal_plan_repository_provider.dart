import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/infrastructure/infrastructure.dart';

part 'meal_plan_repository_provider.g.dart';

@riverpod
MealPlanRepository mealPlanRepository(Ref ref) {
  return MealPlanRepositoryImpl(SupabaseMealPlanDatasource());
}