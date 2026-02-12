import '../../domain/domain.dart';

class UserPreferencesMapper {
  static UserPreferences fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      dietaryRestrictions: (map['dietary_restrictions'] as List?)?.cast<String>(),
      allergies: (map['allergies'] as List?)?.cast<String>(),
      preferredCuisines: (map['preferred_cuisines'] as List?)?.cast<String>(),
      healthGoals: (map['health_goals'] as List?)?.cast<String>(),
      cookingSkillLevel: map['cooking_skill_level'] as String?,
      timeAvailability: map['time_availability'] as String?,
      dislikedFoods: (map['disliked_foods'] as List?)?.cast<String>(),
      likedFoods: (map['liked_foods'] as List?)?.cast<String>(),
      householdSize: map['household_size'] is int
          ? map['household_size'] as int
          : (map['household_size'] as num?)?.toInt(),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  static Map<String, dynamic> toMap(UserPreferences preferences) {
    return {
      'id': preferences.id,
      'user_id': preferences.userId,
      'dietary_restrictions': preferences.dietaryRestrictions,
      'allergies': preferences.allergies,
      'preferred_cuisines': preferences.preferredCuisines,
      'health_goals': preferences.healthGoals,
      'cooking_skill_level': preferences.cookingSkillLevel,
      'time_availability': preferences.timeAvailability,
      'disliked_foods': preferences.dislikedFoods,
      'liked_foods': preferences.likedFoods,
      'household_size': preferences.householdSize,
      'created_at': preferences.createdAt?.toIso8601String(),
      'updated_at': preferences.updatedAt?.toIso8601String(),
    };
  }
}

