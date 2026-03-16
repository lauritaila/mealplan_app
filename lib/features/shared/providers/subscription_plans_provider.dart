import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/providers/supabase_provider.dart';

class SubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final String? description;
  final Map<String, dynamic>? features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.features,
  });

  List<String> descriptionList(String languageCode) {
    final featMap = features?['description'] as Map<String, dynamic>?;
    if (featMap == null) return [];
    final items = featMap[languageCode] ?? featMap['en'];
    if (items is List) {
      return items.whereType<String>().toList();
    }
    return [];
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      features: json['features'] as Map<String, dynamic>?,
    );
  }
}

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase
      .from('subscription_plans')
      .select('id, name, price, description, features')
      .order('price', ascending: true);

  return (response as List<dynamic>)
      .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
      .toList();
});
