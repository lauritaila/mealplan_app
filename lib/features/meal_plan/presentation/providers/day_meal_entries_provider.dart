import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

final selectedMealPlanDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final mealPlanDayEntriesProvider =
    FutureProvider.family<List<DayMealEntry>, DateTime>((ref, date) async {
      final authState = ref.watch(authProvider);
      if (authState is! AuthenticatedAuthState) {
        throw const PermissionAppError.unauthorized();
      }

      final repo = ref.watch(mealPlanRepositoryProvider);
      return repo.getDayMealEntries(
        authState.user.id,
        date: _formatApiDate(date),
      );
    });

String _formatApiDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
