import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

final mealPlanDayEntriesProvider = FutureProvider<List<DayMealEntry>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthenticatedAuthState) {
    throw const PermissionAppError.unauthorized();
  }

  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getDayMealEntries(authState.user.id);
});
