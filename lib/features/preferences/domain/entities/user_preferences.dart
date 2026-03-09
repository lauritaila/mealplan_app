class UserPreferences {
  final int? id;
  final String userId;
  final List<String>? dietaryRestrictions;
  final List<String>? allergies;
  final List<String>? preferredCuisines;
  final List<String>? healthGoals;
  final String? cookingSkillLevel;
  final String? timeAvailability;
  final List<String>? dislikedFoods;
  final List<String>? likedFoods;
  final int? householdSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    required this.userId,
    this.dietaryRestrictions,
    this.allergies,
    this.preferredCuisines,
    this.healthGoals,
    this.cookingSkillLevel,
    this.timeAvailability,
    this.dislikedFoods,
    this.likedFoods,
    this.householdSize,
    this.createdAt,
    this.updatedAt,
  });
}
