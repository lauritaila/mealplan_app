import 'package:meal_plan_app/features/shared/infrastructure/models/subscription_dtos.dart';

abstract class SubscriptionDatasource {
  Future<List<SubscriptionPlanResponseDto>> getSubscriptionPlans();
  Future<ValidateCodeResponseDto> validatePromotionCode({
    required String code,
  });
}
