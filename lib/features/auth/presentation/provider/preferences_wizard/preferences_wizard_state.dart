import 'package:meal_plan_app/features/preferences/domain/domain.dart';

enum FormStatus { initial, submitting, success, error }

class PreferencesWizardState {
  final int step;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> preferredCuisines;
  final List<String> healthGoals;
  final String? cookingSkillLevel;
  final String? timeAvailability;
  final List<String> dislikedFoods;
  final List<String> likedFoods;
  final int householdSize;

  final FormStatus formStatus;
  final String? errorCode;
  final String? errorMessage;

  final String? customAllergy;

  PreferencesWizardState({
    this.step = 0,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.preferredCuisines = const [],
    this.healthGoals = const [],
    this.cookingSkillLevel,
    this.timeAvailability,
    this.dislikedFoods = const [],
    this.likedFoods = const [],
    this.householdSize = 1,
    this.formStatus = FormStatus.initial,
    this.errorCode,
    this.errorMessage,
    this.customAllergy,
  });

  PreferencesWizardState copyWith({
    int? step,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? preferredCuisines,
    List<String>? healthGoals,
    String? cookingSkillLevel,
    String? timeAvailability,
    List<String>? dislikedFoods,
    List<String>? likedFoods,
    int? householdSize,
    FormStatus? formStatus,
    String? errorCode,
    String? errorMessage,
    String? customAllergy,
  }) {
    return PreferencesWizardState(
      step: step ?? this.step,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      preferredCuisines: preferredCuisines ?? this.preferredCuisines,
      healthGoals: healthGoals ?? this.healthGoals,
      cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
      timeAvailability: timeAvailability ?? this.timeAvailability,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      likedFoods: likedFoods ?? this.likedFoods,
      householdSize: householdSize ?? this.householdSize,
      formStatus: formStatus ?? this.formStatus,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      customAllergy: customAllergy ?? this.customAllergy,
    );
  }

  UserPreferences toUserPreferences(String userId) {
    return UserPreferences(
      userId: userId,
      dietaryRestrictions: dietaryRestrictions,
      allergies: allergies,
      preferredCuisines: preferredCuisines,
      healthGoals: healthGoals,
      cookingSkillLevel: cookingSkillLevel,
      timeAvailability: timeAvailability,
      dislikedFoods: dislikedFoods,
      likedFoods: likedFoods,
      householdSize: householdSize,
    );
  }
}
