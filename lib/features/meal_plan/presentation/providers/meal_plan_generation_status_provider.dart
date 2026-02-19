import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

final mealPlanGenerationStatusProvider =
    FutureProvider<MealPlanGenerationStatus>((ref) async {
      final userId = ref.watch(
        authProvider.select((state) {
          if (state is AuthenticatedAuthState) {
            return state.user.id;
          }
          return null;
        }),
      );

      if (userId == null) {
        throw const PermissionAppError.unauthorized();
      }

      final repository = ref.read(mealPlanRepositoryProvider);
      final result = await repository.getMealPlanGenerationStatus(userId);
      return result;
    });
