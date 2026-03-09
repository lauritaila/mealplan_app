import 'package:meal_plan_app/features/grocery_list/domain/entities/entities.dart';

abstract class GroceryRepository {
  // --- Grocery Lists ---
  Future<List<GroceryList>> getGroceryLists();
  Future<GroceryList> createGroceryList({
    required String name,
    int? mealPlanId,
  });
  Future<GroceryListDetail> getGroceryListDetail(int id);
  Future<GroceryList> updateGroceryList(int id, {required String name});
  Future<void> deleteGroceryList(int id);

  // --- Grocery List Items ---
  Future<GroceryListItem> addGroceryListItem(
    int listId, {
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
  });
  Future<GroceryListItem> updateGroceryListItem(
    int listId,
    int itemId, {
    double? quantity,
    bool? checked,
  });
  Future<void> deleteGroceryListItem(int listId, int itemId);

  // --- Pantry ---
  Future<List<PantryItem>> getPantryItems();
  Future<PantryItem> addPantryItem({
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
    String? category,
    String? expiresAt,
  });
  Future<PantryItem> updatePantryItem(
    int id, {
    double? quantity,
    String? expiresAt,
  });
  Future<void> deletePantryItem(int id);

  // --- Import ---
  Future<void> importMealPlan(int groceryListId, int mealPlanId);
  Future<void> importRecipe(int groceryListId, int recipeId, {int? servings});
}
