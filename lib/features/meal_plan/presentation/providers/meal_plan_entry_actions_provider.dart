import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_entry_actions_provider.g.dart';

enum MealPlanEntryActionStatus { initial, loading, success, error }

class MealPlanEntryActionState {
  final MealPlanEntryActionStatus status;
  final String? errorMessage;
  final DayMealEntry? updatedEntry;

  const MealPlanEntryActionState({
    this.status = MealPlanEntryActionStatus.initial,
    this.errorMessage,
    this.updatedEntry,
  });

  MealPlanEntryActionState copyWith({
    MealPlanEntryActionStatus? status,
    String? errorMessage,
    DayMealEntry? updatedEntry,
    bool clearError = false,
    bool clearEntry = false,
  }) {
    return MealPlanEntryActionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      updatedEntry: clearEntry ? null : updatedEntry ?? this.updatedEntry,
    );
  }
}

@riverpod
class MealPlanEntryActions extends _$MealPlanEntryActions {
  @override
  MealPlanEntryActionState build() {
    return const MealPlanEntryActionState();
  }

  Future<void> deleteEntry(int entryId) async {
    state = state.copyWith(
      status: MealPlanEntryActionStatus.loading,
      clearError: true,
      clearEntry: true,
    );
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.deleteMealPlanEntry(entryId);
      state = state.copyWith(status: MealPlanEntryActionStatus.success);
    } on AppError catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<DayMealEntry?> changeRecipe(
    int entryId,
    ChangeMealPlanRecipeRequest request,
  ) async {
    state = state.copyWith(
      status: MealPlanEntryActionStatus.loading,
      clearError: true,
      clearEntry: true,
    );
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final updated = await repo.changeMealPlanRecipe(entryId, request);
      state = state.copyWith(
        status: MealPlanEntryActionStatus.success,
        updatedEntry: updated,
      );
      return updated;
    } on AppError catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<void> deletePlan(int mealPlanId, {String? deleteDescription}) async {
    state = state.copyWith(
      status: MealPlanEntryActionStatus.loading,
      clearError: true,
      clearEntry: true,
    );
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.deleteMealPlan(
        mealPlanId,
        deleteDescription: deleteDescription,
      );
      state = state.copyWith(status: MealPlanEntryActionStatus.success);
    } on AppError catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const MealPlanEntryActionState();
  }

  Future<void> moveEntryToDate(int entryId, DateTime newDate) async {
    state = state.copyWith(
      status: MealPlanEntryActionStatus.loading,
      clearError: true,
      clearEntry: true,
    );
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.moveMealPlanEntryToDate(entryId, newDate);
      state = state.copyWith(status: MealPlanEntryActionStatus.success);
    } on AppError catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<DayMealEntry?> swapRecipe(int entryId, int recipeId) async {
    state = state.copyWith(
      status: MealPlanEntryActionStatus.loading,
      clearError: true,
      clearEntry: true,
    );
    try {
      final repo = ref.read(mealPlanRepositoryProvider);
      final updated = await repo.swapMealPlanRecipe(entryId, recipeId);
      state = state.copyWith(
        status: MealPlanEntryActionStatus.success,
        updatedEntry: updated,
      );
      return updated;
    } on AppError catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        status: MealPlanEntryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }
}
