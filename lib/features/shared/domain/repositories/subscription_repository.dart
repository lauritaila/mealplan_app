import 'package:meal_plan_app/features/shared/domain/entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getSubscriptionPlans();
  Future<PromoCodeValidationResult> validatePromotionCode({
    required String code,
  });
}
