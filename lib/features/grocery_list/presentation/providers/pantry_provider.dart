import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pantry_provider.g.dart';

@riverpod
Future<List<PantryItem>> pantryItems(Ref ref) async {
  final repo = ref.watch(groceryRepositoryProvider);
  return repo.getPantryItems();
}

sealed class PantryDisplayItem {}

class PantryHeaderDisplayItem extends PantryDisplayItem {
  final String category;
  PantryHeaderDisplayItem(this.category);
}

class PantryItemDisplayItem extends PantryDisplayItem {
  final PantryItem item;
  PantryItemDisplayItem(this.item);
}

@riverpod
Future<List<PantryDisplayItem>> groupedPantryItems(Ref ref) async {
  final items = await ref.watch(pantryItemsProvider.future);
  
  // Group logic
  final grouped = <String, List<PantryItem>>{};
  for (final item in items) {
    // Use raw category or a sentinel for "Other"
    final cat = (item.category?.isNotEmpty == true) ? item.category! : '__other__';
    grouped.putIfAbsent(cat, () => []).add(item);
  }

  // Flatten logic
  final categories = grouped.keys.toList()..sort();
  final displayItems = <PantryDisplayItem>[];
  
  for (final cat in categories) {
    displayItems.add(PantryHeaderDisplayItem(cat));
    for (final item in grouped[cat]!) {
      displayItems.add(PantryItemDisplayItem(item));
    }
  }

  return displayItems;
}
