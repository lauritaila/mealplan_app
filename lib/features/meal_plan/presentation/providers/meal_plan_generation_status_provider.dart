import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

final mealPlanGenerationStatusProvider =
    FutureProvider<MealPlanGenerationStatus>((ref) async {
      final authState = ref.watch(authProvider);
      if (authState is! AuthenticatedAuthState) {
        throw Exception('User not authenticated');
      }

      final repository = ref.read(mealPlanRepositoryProvider);
      print(
        'Fetching meal plan generation status for user: ${authState.user.id}',
      );
      final result = await repository.getMealPlanGenerationStatus(
        authState.user.id,
      );
      print('Status fetched: $result');
      return result;
    });
