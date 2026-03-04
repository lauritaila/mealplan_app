import 'package:meal_plan_app/features/grocery_list/domain/domain.dart';

class GroceryRepositoryImpl extends GroceryRepository {
  final GroceryDatasource datasource;

  GroceryRepositoryImpl(this.datasource);

  @override
  Future<List<GroceryList>> getGroceryLists() => datasource.getGroceryLists();

  @override
  Future<GroceryList> createGroceryList({
    required String name,
    int? mealPlanId,
  }) => datasource.createGroceryList(name: name, mealPlanId: mealPlanId);

  @override
  Future<GroceryListDetail> getGroceryListDetail(int id) =>
      datasource.getGroceryListDetail(id);

  @override
  Future<GroceryList> updateGroceryList(int id, {required String name}) =>
      datasource.updateGroceryList(id, name: name);

  @override
  Future<void> deleteGroceryList(int id) => datasource.deleteGroceryList(id);

  @override
  Future<GroceryListItem> addGroceryListItem(
    int listId, {
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
  }) => datasource.addGroceryListItem(
    listId,
    quantity: quantity,
    unit: unit,
    ingredientName: ingredientName,
    ingredientId: ingredientId,
  );

  @override
  Future<GroceryListItem> updateGroceryListItem(
    int listId,
    int itemId, {
    double? quantity,
    bool? checked,
  }) => datasource.updateGroceryListItem(
    listId,
    itemId,
    quantity: quantity,
    checked: checked,
  );

  @override
  Future<void> deleteGroceryListItem(int listId, int itemId) =>
      datasource.deleteGroceryListItem(listId, itemId);

  @override
  Future<List<PantryItem>> getPantryItems() => datasource.getPantryItems();

  @override
  Future<PantryItem> addPantryItem({
    required double quantity,
    required String unit,
    String? ingredientName,
    int? ingredientId,
    String? category,
    String? expiresAt,
  }) => datasource.addPantryItem(
    quantity: quantity,
    unit: unit,
    ingredientName: ingredientName,
    ingredientId: ingredientId,
    category: category,
    expiresAt: expiresAt,
  );

  @override
  Future<PantryItem> updatePantryItem(
    int id, {
    double? quantity,
    String? expiresAt,
  }) =>
      datasource.updatePantryItem(id, quantity: quantity, expiresAt: expiresAt);

  @override
  Future<void> deletePantryItem(int id) => datasource.deletePantryItem(id);

  @override
  Future<void> importMealPlan(int groceryListId, int mealPlanId) =>
      datasource.importMealPlan(groceryListId, mealPlanId);

  @override
  Future<void> importRecipe(int groceryListId, int recipeId, {int? servings}) =>
      datasource.importRecipe(groceryListId, recipeId, servings: servings);
}
