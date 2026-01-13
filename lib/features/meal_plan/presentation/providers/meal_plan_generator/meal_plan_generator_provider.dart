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

      final request = NewMealPlanRequest(
        userId: authState.user.id,
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
            : 'No se pudo generar el plan. Intenta de nuevo.',
        clearGeneratedPlan: true,
      );
    }
  }

  void reset() {
    state = MealPlanGeneratorState();
  }
}
