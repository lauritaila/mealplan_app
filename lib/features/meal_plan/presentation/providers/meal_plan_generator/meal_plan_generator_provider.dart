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
  final String? errorCode;
  final MealPlanResponse? generatedPlan;

  MealPlanGeneratorState({
    this.status = MealPlanGeneratorStatus.initial,
    this.errorMessage,
    this.errorCode,
    this.generatedPlan,
  });

  MealPlanGeneratorState copyWith({
    MealPlanGeneratorStatus? status,
    String? errorMessage,
    String? errorCode,
    MealPlanResponse? generatedPlan,
    bool clearGeneratedPlan = false,
    bool clearError = false,
  }) {
    return MealPlanGeneratorState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
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
    required bool usePantry,
  }) async {
    state = state.copyWith(
      status: MealPlanGeneratorStatus.loading,
      clearError: true,
    );

    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthenticatedAuthState) {
        throw const MealPlanAppError.notAuthenticated();
      }

      final user = authState.user;
      if (user.permissions != null) {
        final allowedDays = user.permissions!.permissions.mealPlanDays;
        if (!allowedDays.contains(numberOfDays)) {
          throw const MealPlanAppError.daysNotAllowed();
        }
        final allowedTypes = user.permissions!.permissions.mealPlanTypeFood;
        if (!mealTypes.every((type) => allowedTypes.contains(type))) {
          throw const MealPlanAppError.typesNotAllowed();
        }
      }

      final mealPlansState = ref.read(mealPlansProvider);
      DateTime startDate = DateTime.now();

      final List<dynamic> currentPlans;
      if (mealPlansState is AsyncData) {
        currentPlans = mealPlansState.value!;
      } else if (mealPlansState is AsyncLoading) {
        // Option A: wait for it
        currentPlans = await ref.read(mealPlansProvider.future);
      } else {
        // Error or other: assume empty or propagate error
        currentPlans = [];
      }

      if (currentPlans.isNotEmpty) {
        DateTime latestEndDate = currentPlans
            .map((p) => p.endDate)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        if (latestEndDate.isAfter(
          startDate.subtract(const Duration(days: 1)),
        )) {
          startDate = latestEndDate.add(const Duration(days: 1));
        }
      }

      final startDateStr =
          '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

      final request = NewMealPlanRequest(
        numberOfDays: numberOfDays,
        quantityOfPeople: quantityOfPeople,
        description: description.isEmpty ? null : description,
        mealTypes: mealTypes.isEmpty ? null : mealTypes,
        startDate: startDateStr,
        usePantry: usePantry,
      );

      final mealPlanRepo = ref.read(mealPlanRepositoryProvider);
      final generatedPlan = await mealPlanRepo.generateMealPlan(request);

      // Refresh remaining quota/status after each successful generation.
      ref.invalidate(mealPlanGenerationStatusProvider);

      state = state.copyWith(
        status: MealPlanGeneratorStatus.success,
        generatedPlan: generatedPlan,
        clearError: true,
      );
    } catch (e) {
      // Keep provider error message concise for UI
      state = state.copyWith(
        status: MealPlanGeneratorStatus.error,
        errorMessage: e is AppError ? e.message : null,
        errorCode: e is AppError
            ? e.code
            : const MealPlanAppError.generateFailed().code,
        clearGeneratedPlan: true,
      );
    }
  }

  void reset() {
    state = MealPlanGeneratorState();
  }
}
