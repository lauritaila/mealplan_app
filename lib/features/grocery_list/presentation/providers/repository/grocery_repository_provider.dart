import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/infrastructure/infrastructure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grocery_repository_provider.g.dart';

@riverpod
GroceryRepository groceryRepository(Ref ref) {
  return GroceryRepositoryImpl(HttpGroceryDatasource());
}
