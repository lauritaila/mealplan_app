import 'package:meal_plan_app/features/grocery_list/domain/entities/entities.dart';

class PantryItemMapper {
  static PantryItem fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: _toInt(map['id']) ?? 0,
      ingredientId: _toInt(map['ingredient_id']),
      ingredientName: (map['ingredient_name'] as String?) ?? '',
      quantity: _toDouble(map['quantity']) ?? 0,
      unit: (map['unit'] as String?) ?? '',
      category: map['category'] as String?,
      expiresAt: _parseDate(map['expires_at']),
    );
  }

  static List<PantryItem> fromList(List<dynamic> list) {
    return list.whereType<Map<String, dynamic>>().map(fromMap).toList();
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  try {
    if (value is DateTime) return value;
    return DateTime.parse(value.toString());
  } catch (_) {
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
