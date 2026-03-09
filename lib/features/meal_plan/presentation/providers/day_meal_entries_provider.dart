import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'day_meal_entries_provider.g.dart';

enum DayMealEntryStatusUpdateStatus { initial, loading, success, error }

class DayMealEntryStatusUpdateState {
  final DayMealEntryStatusUpdateStatus status;
  final String? errorMessage;

  const DayMealEntryStatusUpdateState({
    this.status = DayMealEntryStatusUpdateStatus.initial,
    this.errorMessage,
  });

  DayMealEntryStatusUpdateState copyWith({
    DayMealEntryStatusUpdateStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DayMealEntryStatusUpdateState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class SelectedMealPlanDay extends _$SelectedMealPlanDay {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }
}

@riverpod
Future<List<DayMealEntry>> mealPlanDayEntries(Ref ref, DateTime date) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthenticatedAuthState) {
    throw const PermissionAppError.unauthorized();
  }

  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getDayMealEntries(authState.user.id, date: _formatApiDate(date));
}

@riverpod
class DayMealEntryStatusUpdate extends _$DayMealEntryStatusUpdate {
  @override
  DayMealEntryStatusUpdateState build() {
    return const DayMealEntryStatusUpdateState();
  }

  Future<void> toggleSkipped(DayMealEntry entry, DateTime selectedDate) async {
    state = state.copyWith(
      status: DayMealEntryStatusUpdateStatus.loading,
      clearError: true,
    );

    try {
      final normalizedStatus = _normalizeStatus(entry.status);
      final shouldSkip = normalizedStatus != 'skipped';
      final targetStatus = shouldSkip ? 'skipped' : null;

      final repo = ref.read(mealPlanRepositoryProvider);
      await repo.updateDayMealEntryStatus(entry.entryId, status: targetStatus);

      ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
      state = state.copyWith(
        status: DayMealEntryStatusUpdateStatus.success,
        clearError: true,
      );
    } on AppError catch (e) {
      state = state.copyWith(
        status: DayMealEntryStatusUpdateStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: DayMealEntryStatusUpdateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const DayMealEntryStatusUpdateState();
  }
}

String _formatApiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _normalizeStatus(String? status) {
  if (status == null) return null;
  final value = status.trim().toLowerCase();
  if (value.isEmpty) return null;
  return value == 'skiped' ? 'skipped' : value;
}
