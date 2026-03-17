import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/domain/entities/subscription_plan.dart';
import 'package:meal_plan_app/features/shared/providers/subscription_repository_provider.dart';

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return await repository.getSubscriptionPlans();
});
