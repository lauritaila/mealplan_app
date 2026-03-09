import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grocery_lists_provider.g.dart';

@riverpod
Future<List<GroceryList>> groceryLists(Ref ref) async {
  final repo = ref.watch(groceryRepositoryProvider);
  return repo.getGroceryLists();
}
