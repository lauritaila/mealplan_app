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

  const HomeViewState({
    required this.isAuthenticated,
    required this.showGraceWelcome,
    required this.statusAsync,
    required this.totalAllowed,
    required this.planName,
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
    );
  }

  return HomeViewState(
    isAuthenticated: true,
    showGraceWelcome: authState.showGraceWelcome,
    statusAsync: ref.watch(mealPlanGenerationStatusProvider),
    totalAllowed: authState.user.permissions?.permissions.mealPlanGenerate,
    planName: authState.user.planName,
  );
}
