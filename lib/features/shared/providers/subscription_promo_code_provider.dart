import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/domain/entities/subscription_plan.dart';
import 'package:meal_plan_app/features/shared/providers/subscription_repository_provider.dart';

class PromoCodeState {
  final String? code;
  final int? planId;
  final PlanPricing? monthlyPricing;
  final PlanPricing? annualPricing;
  final bool isLoading;
  final String? error;

  PromoCodeState({
    this.code,
    this.planId,
    this.monthlyPricing,
    this.annualPricing,
    this.isLoading = false,
    this.error,
  });

  PromoCodeState copyWith({
    String? code,
    int? planId,
    PlanPricing? monthlyPricing,
    PlanPricing? annualPricing,
    bool? isLoading,
    String? error,
  }) {
    return PromoCodeState(
      code: code ?? this.code,
      planId: planId ?? this.planId,
      monthlyPricing: monthlyPricing ?? this.monthlyPricing,
      annualPricing: annualPricing ?? this.annualPricing,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PromoCodeNotifier extends StateNotifier<PromoCodeState> {
  final Ref _ref;

  PromoCodeNotifier(this._ref) : super(PromoCodeState());

  Future<bool> validateCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      final result = await repository.validatePromotionCode(code: code);

      if (result.isValid) {
        state = state.copyWith(
          code: code,
          planId: result.planId,
          monthlyPricing: result.monthly,
          annualPricing: result.annual,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid code', // Will be shown localized in UI
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
  void clearCode() {
    state = PromoCodeState();
  }
}

final subscriptionPromoCodeProvider = StateNotifierProvider<PromoCodeNotifier, PromoCodeState>((ref) {
  return PromoCodeNotifier(ref);
});
