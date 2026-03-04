import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/pantry_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pantry_actions_provider.g.dart';

enum PantryActionStatus { initial, loading, success, error }

class PantryActionState {
  final PantryActionStatus status;
  final String? errorMessage;

  const PantryActionState({
    this.status = PantryActionStatus.initial,
    this.errorMessage,
  });

  PantryActionState copyWith({
    PantryActionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PantryActionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class PantryActions extends _$PantryActions {
  @override
  PantryActionState build() => const PantryActionState();

  GroceryRepository get _repo => ref.read(groceryRepositoryProvider);

  Future<PantryItem?> addItem({
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
    String? category,
    String? expiresAt,
  }) async {
    state = state.copyWith(
      status: PantryActionStatus.loading,
      clearError: true,
    );
    try {
      final result = await _repo.addPantryItem(
        quantity: quantity,
        unit: unit,
        ingredientName: ingredientName,
        ingredientId: ingredientId,
        category: category,
        expiresAt: expiresAt,
      );
      ref.invalidate(pantryItemsProvider);
      state = state.copyWith(status: PantryActionStatus.success);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: PantryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<PantryItem?> updateItem(
    int id, {
    double? quantity,
    String? expiresAt,
  }) async {
    state = state.copyWith(
      status: PantryActionStatus.loading,
      clearError: true,
    );
    try {
      final result = await _repo.updatePantryItem(
        id,
        quantity: quantity,
        expiresAt: expiresAt,
      );
      ref.invalidate(pantryItemsProvider);
      state = state.copyWith(status: PantryActionStatus.success);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: PantryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteItem(int id) async {
    state = state.copyWith(
      status: PantryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.deletePantryItem(id);
      ref.invalidate(pantryItemsProvider);
      state = state.copyWith(status: PantryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: PantryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const PantryActionState();
}
