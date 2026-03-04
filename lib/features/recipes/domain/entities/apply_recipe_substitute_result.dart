class ApplyRecipeSubstituteResult {
  final int originalRecipeId;
  final int newRecipeId;
  final String? newRecipeName;

  const ApplyRecipeSubstituteResult({
    required this.originalRecipeId,
    required this.newRecipeId,
    this.newRecipeName,
  });
}
