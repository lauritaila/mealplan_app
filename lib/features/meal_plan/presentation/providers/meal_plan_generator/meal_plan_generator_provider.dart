import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_generator_provider.g.dart';

// Enum para el estado del formulario
enum MealPlanGeneratorStatus { initial, loading, success, error }

// Clase de estado
class MealPlanGeneratorState {
  final MealPlanGeneratorStatus status;
  final String? errorMessage;
  final MealPlanResponse? generatedPlan;

  MealPlanGeneratorState({
    this.status = MealPlanGeneratorStatus.initial,
    this.errorMessage,
    this.generatedPlan,
  });

  MealPlanGeneratorState copyWith({
    MealPlanGeneratorStatus? status,
    String? errorMessage,
    MealPlanResponse? generatedPlan,
    bool clearGeneratedPlan = false,
    bool clearError = false,
  }) {
    return MealPlanGeneratorState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      generatedPlan: clearGeneratedPlan
          ? null
          : generatedPlan ?? this.generatedPlan,
    );
  }
}

@riverpod
List<int> availableDurations(Ref ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthenticatedAuthState &&
      authState.user.permissions != null) {
    final days = authState.user.permissions!.permissions.mealPlanDays;
    return days.isNotEmpty ? days : [3, 5, 7, 14];
  }
  return [3, 5, 7, 14];
}

@riverpod
List<String> availableMealTypes(Ref ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthenticatedAuthState &&
      authState.user.permissions != null) {
    final types = authState.user.permissions!.permissions.mealPlanTypeFood;
    return types.isNotEmpty ? types : ['breakfast', 'lunch', 'dinner', 'snack'];
  }
  return ['breakfast', 'lunch', 'dinner', 'snack'];
}

@riverpod
bool shouldShowMealTypeSelection(Ref ref) {
  final types = ref.watch(availableMealTypesProvider);
  return types.length > 1;
}

// El provider
@riverpod
class MealPlanGenerator extends _$MealPlanGenerator {
  @override
  MealPlanGeneratorState build() {
    return MealPlanGeneratorState();
  }

  Future<void> generatePlan({
    required String description,
    required int numberOfDays,
    required int quantityOfPeople,
    required List<String> mealTypes,
  }) async {
    state = state.copyWith(
      status: MealPlanGeneratorStatus.loading,
      clearError: true,
    );

    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthenticatedAuthState) {
        throw Exception('User not authenticated');
      }

      final user = authState.user;
      if (user.permissions != null) {
        final allowedDays = user.permissions!.permissions.mealPlanDays;
        if (!allowedDays.contains(numberOfDays)) {
          throw Exception('Number of days not allowed');
        }
        final allowedTypes = user.permissions!.permissions.mealPlanTypeFood;
        if (!mealTypes.every((type) => allowedTypes.contains(type))) {
          throw Exception('Meal types not allowed');
        }
      }

      final request = NewMealPlanRequest(
        numberOfDays: numberOfDays,
        quantityOfPeople: quantityOfPeople,
        description: description.isEmpty ? null : description,
        mealTypes: mealTypes.isEmpty ? null : mealTypes,
      );

      final mealPlanRepo = ref.read(mealPlanRepositoryProvider);
      final generatedPlan = await mealPlanRepo.generateMealPlan(request);

      state = state.copyWith(
        status: MealPlanGeneratorStatus.success,
        generatedPlan: generatedPlan,
        clearError: true,
      );
    } catch (e) {
      // Keep provider error message concise for UI
      state = state.copyWith(
        status: MealPlanGeneratorStatus.error,
        errorMessage: e is AppError
            ? e.message
            : 'Could not generate the plan. Try again.',
        clearGeneratedPlan: true,
      );
    }
  }

  void reset() {
    state = MealPlanGeneratorState();
  }
}
