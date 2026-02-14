import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_provider.g.dart';

class HomeViewState {
  final bool isAuthenticated;
  final bool showGraceWelcome;
  final AsyncValue<MealPlanGenerationStatus>? statusAsync;
  final int? totalAllowed;
  final String? planName;
  final bool isFreePlan;

  const HomeViewState({
    required this.isAuthenticated,
    required this.showGraceWelcome,
    required this.statusAsync,
    required this.totalAllowed,
    required this.planName,
    required this.isFreePlan,
  });
}

@riverpod
bool homeShowGraceWelcome(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthenticatedAuthState && authState.showGraceWelcome;
}

@riverpod
HomeViewState homeViewState(Ref ref) {
  final authState = ref.watch(authProvider);

  if (authState is! AuthenticatedAuthState) {
    return const HomeViewState(
      isAuthenticated: false,
      showGraceWelcome: false,
      statusAsync: null,
      totalAllowed: null,
      planName: null,
      isFreePlan: false,
    );
  }

  final planName = authState.user.planName;
  // Consider planName null or 'free' (case-insensitive) as free plan
  final isFreePlan =
      planName == null || planName.trim().toLowerCase() == 'free';

  return HomeViewState(
    isAuthenticated: true,
    showGraceWelcome: authState.showGraceWelcome,
    statusAsync: ref.watch(mealPlanGenerationStatusProvider),
    totalAllowed: authState.user.permissions?.permissions.mealPlanGenerate,
    planName: planName,
    isFreePlan: isFreePlan,
  );
}
