import 'package:meal_plan_app/features/shared/domain/entities/subscription_plan.dart';
import 'package:meal_plan_app/features/shared/domain/repositories/subscription_repository.dart';
import 'package:meal_plan_app/features/shared/infrastructure/datasources/subscription_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionDatasource _datasource;

  SubscriptionRepositoryImpl(this._datasource);

  @override
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final dtos = await _datasource.getSubscriptionPlans();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<PromoCodeValidationResult> validatePromotionCode({
    required String code,
  }) async {
    final response = await _datasource.validatePromotionCode(
      code: code,
    );
    
    return response.toEntity();
  }
}
