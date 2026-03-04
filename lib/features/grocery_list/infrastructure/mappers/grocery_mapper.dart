import 'package:meal_plan_app/features/grocery_list/domain/entities/entities.dart';

class GroceryListMapper {
  static GroceryList fromMap(Map<String, dynamic> map) {
    return GroceryList(
      id: _toInt(map['id']) ?? 0,
      name: (map['name'] as String?) ?? '',
      mealPlanId: _toInt(map['meal_plan_id']),
      createdAt: _parseDate(map['created_at']),
    );
  }

  static List<GroceryList> fromList(List<dynamic> list) {
    return list.whereType<Map<String, dynamic>>().map(fromMap).toList();
  }
}

class GroceryListDetailMapper {
  static GroceryListDetail fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(GroceryListItemMapper.fromMap)
        .toList();

    return GroceryListDetail(
      id: _toInt(map['id']) ?? 0,
      name: (map['name'] as String?) ?? '',
      mealPlanId: _toInt(map['meal_plan_id']),
      createdAt: _parseDate(map['created_at']),
      items: items,
    );
  }
}

class GroceryListItemMapper {
  static GroceryListItem fromMap(Map<String, dynamic> map) {
    return GroceryListItem(
      id: _toInt(map['id']) ?? 0,
      ingredientName: (map['ingredient_name'] as String?) ?? '',
      quantity: _toDouble(map['quantity']) ?? 0,
      unit: (map['unit'] as String?) ?? '',
      checked: _toBool(map['is_checked']) || _toBool(map['checked']),
      isCoveredByPantry: _toBool(map['is_covered_by_pantry']),
    );
  }
}

/// Parses a date from dynamic input.
/// Returns null if the value is null or malformed.
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    if (value is DateTime) return value;
    return DateTime.parse(value.toString());
  } catch (e) {
    print('Warning: Error parsing date "$value": $e');
    return null;
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value.toString().trim().toLowerCase();
  return s == '1' || s == 'true' || s == 'yes';
}
