class ApplyRecipeSubstituteRequest {
  final int recipeIngredientId;
  final String substituteName;
  final String ratio;
  final String reason;
  final String category;

  const ApplyRecipeSubstituteRequest({
    required this.recipeIngredientId,
    required this.substituteName,
    required this.ratio,
    required this.reason,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipe_ingredient_id': recipeIngredientId,
      'substitute_name': substituteName,
      'ratio': ratio,
      'reason': reason,
      'category': category,
    };
  }
}
