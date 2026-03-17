import 'package:meal_plan_app/features/shared/domain/entities/subscription_plan.dart';

class SubscriptionPlanResponseDto {
  final int id;
  final String name;
  final List<String> description;
  final PricingDto monthly;
  final PricingDto annual;

  SubscriptionPlanResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.monthly,
    required this.annual,
  });

  factory SubscriptionPlanResponseDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: List<String>.from(json['description'] as List),
      monthly: PricingDto.fromJson(json['monthly'] as Map<String, dynamic>),
      annual: PricingDto.fromJson(json['annual'] as Map<String, dynamic>),
    );
  }

  SubscriptionPlan toEntity() {
    return SubscriptionPlan(
      id: id,
      name: name,
      description: description,
      monthly: monthly.toEntity(),
      annual: annual.toEntity(),
    );
  }
}

class PricingDto {
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final double discountAmount;
  final bool isDiscounted;
  final String currency;

  PricingDto({
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.discountAmount,
    required this.isDiscounted,
    required this.currency,
  });

  factory PricingDto.fromJson(Map<String, dynamic> json) {
    return PricingDto(
      originalPrice: (json['originalPrice'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
      discountPercentage: json['discountPercentage'] as int,
      discountAmount: (json['discountAmount'] as num).toDouble(),
      isDiscounted: json['isDiscounted'] as bool,
      currency: json['currency'] as String,
    );
  }

  PlanPricing toEntity() {
    return PlanPricing(
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      isDiscounted: isDiscounted,
      currency: currency,
    );
  }
}

class ValidateCodeResponseDto {
  final bool isValid;
  final int? planId;
  final PricingDto monthly;
  final PricingDto annual;
  final Map<String, dynamic>? promotionDetails;

  ValidateCodeResponseDto({
    required this.isValid,
    this.planId,
    required this.monthly,
    required this.annual,
    this.promotionDetails,
  });

  factory ValidateCodeResponseDto.fromJson(Map<String, dynamic> json) {
    return ValidateCodeResponseDto(
      isValid: json['isValid'] as bool,
      planId: json['planId'] as int?,
      monthly: PricingDto.fromJson(json['monthly'] as Map<String, dynamic>),
      annual: PricingDto.fromJson(json['annual'] as Map<String, dynamic>),
      promotionDetails: json['promotionDetails'] as Map<String, dynamic>?,
    );
  }

  PromoCodeValidationResult toEntity() {
    return PromoCodeValidationResult(
      isValid: isValid,
      planId: planId,
      monthly: monthly.toEntity(),
      annual: annual.toEntity(),
      promotionDetails: promotionDetails,
    );
  }
}
