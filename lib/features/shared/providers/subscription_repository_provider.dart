import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/domain/repositories/subscription_repository.dart';
import 'package:meal_plan_app/features/shared/infrastructure/datasources/subscription_datasource_impl.dart';
import 'package:meal_plan_app/features/shared/infrastructure/repositories/subscription_repository_impl.dart';
import 'package:meal_plan_app/features/shared/providers/dio_provider.dart';

final subscriptionDatasourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return SubscriptionDatasourceImpl(dio);
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = ref.watch(subscriptionDatasourceProvider);
  return SubscriptionRepositoryImpl(datasource);
});
