import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grocery_actions_provider.g.dart';

enum GroceryActionStatus { initial, loading, success, error }

class GroceryActionState {
  final GroceryActionStatus status;
  final String? errorMessage;

  const GroceryActionState({
    this.status = GroceryActionStatus.initial,
    this.errorMessage,
  });

  GroceryActionState copyWith({
    GroceryActionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroceryActionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class GroceryActions extends _$GroceryActions {
  @override
  GroceryActionState build() => const GroceryActionState();

  GroceryRepository get _repo => ref.read(groceryRepositoryProvider);

  // --- Lists ---

  Future<GroceryList?> createList({
    required String name,
    int? mealPlanId,
  }) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      final result = await _repo.createGroceryList(
        name: name,
        mealPlanId: mealPlanId,
      );
      ref.invalidate(groceryListsProvider);
      state = state.copyWith(status: GroceryActionStatus.success);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> updateList(int id, {required String name}) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.updateGroceryList(id, name: name);
      ref.invalidate(groceryListsProvider);
      state = state.copyWith(status: GroceryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteList(int id) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.deleteGroceryList(id);
      ref.invalidate(groceryListsProvider);
      state = state.copyWith(status: GroceryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // --- Items ---

  Future<GroceryListItem?> addItem(
    int listId, {
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
  }) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      final result = await _repo.addGroceryListItem(
        listId,
        quantity: quantity,
        unit: unit,
        ingredientName: ingredientName,
        ingredientId: ingredientId,
      );
      ref.invalidate(groceryListDetailProvider(listId));
      state = state.copyWith(status: GroceryActionStatus.success);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<GroceryListItem?> updateItem(
    int listId,
    int itemId, {
    double? quantity,
    bool? checked,
  }) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      final result = await _repo.updateGroceryListItem(
        listId,
        itemId,
        quantity: quantity,
        checked: checked,
      );
      ref.invalidate(groceryListDetailProvider(listId));
      state = state.copyWith(status: GroceryActionStatus.success);
      return result;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> deleteItem(int listId, int itemId) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.deleteGroceryListItem(listId, itemId);
      ref.invalidate(groceryListDetailProvider(listId));
      state = state.copyWith(status: GroceryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // --- Import ---

  Future<bool> importMealPlan(int groceryListId, int mealPlanId) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.importMealPlan(groceryListId, mealPlanId);
      ref.invalidate(groceryListDetailProvider(groceryListId));
      state = state.copyWith(status: GroceryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> importRecipe(
    int groceryListId,
    int recipeId, {
    int? servings,
  }) async {
    state = state.copyWith(
      status: GroceryActionStatus.loading,
      clearError: true,
    );
    try {
      await _repo.importRecipe(groceryListId, recipeId, servings: servings);
      ref.invalidate(groceryListDetailProvider(groceryListId));
      state = state.copyWith(status: GroceryActionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: GroceryActionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const GroceryActionState();
}
