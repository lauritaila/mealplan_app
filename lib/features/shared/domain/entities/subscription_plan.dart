class SubscriptionPlan {
  final int id;
  final String name;
  final List<String> description;
  final PlanPricing monthly;
  final PlanPricing annual;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthly,
    required this.annual,
  });
}

class PlanPricing {
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final double discountAmount;
  final bool isDiscounted;
  final String currency;

  const PlanPricing({
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.discountAmount,
    required this.isDiscounted,
    required this.currency,
  });
}

class PromoCodeValidationResult {
  final bool isValid;
  final int? planId;
  final PlanPricing monthly;
  final PlanPricing annual;
  final Map<String, dynamic>? promotionDetails;

  const PromoCodeValidationResult({
    required this.isValid,
    this.planId,
    required this.monthly,
    required this.annual,
    this.promotionDetails,
  });
}
