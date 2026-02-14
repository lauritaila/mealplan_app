import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/preferences/domain/domain.dart';
import 'package:meal_plan_app/features/preferences/presentation/providers/preferences_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferences_details_provider.g.dart';

class PreferencesDetailsState {
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final List<String> healthGoals;
  final String? cookingSkillLevel;
  final String? timeAvailability;
  final List<String> dislikedFoods;
  final List<String> likedFoods;
  final int householdSize;
  final bool hideNutritionValues;
  final String? languageCode;
  final bool isHydrated;

  const PreferencesDetailsState({
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.healthGoals = const [],
    this.cookingSkillLevel,
    this.timeAvailability,
    this.dislikedFoods = const [],
    this.likedFoods = const [],
    this.householdSize = 1,
    this.hideNutritionValues = false,
    this.languageCode,
    this.isHydrated = false,
  });

  PreferencesDetailsState copyWith({
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    List<String>? healthGoals,
    String? Function()? cookingSkillLevel,
    String? Function()? timeAvailability,
    List<String>? dislikedFoods,
    List<String>? likedFoods,
    int? householdSize,
    bool? hideNutritionValues,
    String? Function()? languageCode,
    bool? isHydrated,
  }) {
    return PreferencesDetailsState(
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      healthGoals: healthGoals ?? this.healthGoals,
      cookingSkillLevel: cookingSkillLevel != null
          ? cookingSkillLevel()
          : this.cookingSkillLevel,
      timeAvailability: timeAvailability != null
          ? timeAvailability()
          : this.timeAvailability,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      likedFoods: likedFoods ?? this.likedFoods,
      householdSize: householdSize ?? this.householdSize,
      hideNutritionValues: hideNutritionValues ?? this.hideNutritionValues,
      languageCode: languageCode != null ? languageCode() : this.languageCode,
      isHydrated: isHydrated ?? this.isHydrated,
    );
  }

  UserPreferences toUserPreferences(String userId) {
    return UserPreferences(
      userId: userId,
      dietaryRestrictions: dietaryRestrictions,
      allergies: allergies,
      healthGoals: healthGoals,
      cookingSkillLevel: cookingSkillLevel,
      timeAvailability: timeAvailability,
      dislikedFoods: dislikedFoods,
      likedFoods: likedFoods,
      householdSize: householdSize,
    );
  }
}

@riverpod
class PreferencesDetails extends _$PreferencesDetails {
  @override
  PreferencesDetailsState build() => const PreferencesDetailsState();

  Future<void> hydrateFromServer() async {
    if (state.isHydrated) return;

    final authState = ref.read(authProvider);
    String? languageCode = state.languageCode;
    bool hideNutritionValues = state.hideNutritionValues;
    if (authState is AuthenticatedAuthState) {
      languageCode = authState.user.configurations?['language'] as String?;
      final hideNutritionRaw =
          authState.user.configurations?['hideNutritionValues'];
      if (hideNutritionRaw is bool) {
        hideNutritionValues = hideNutritionRaw;
      }
    }

    try {
      final preferences = await ref
          .read(preferencesRepositoryProvider)
          .fetchUserPreference();

      if (preferences == null) {
        state = state.copyWith(
          languageCode: () => languageCode,
          hideNutritionValues: hideNutritionValues,
          isHydrated: true,
        );
        return;
      }

      state = state.copyWith(
        dietaryRestrictions: preferences.dietaryRestrictions ?? const [],
        allergies: preferences.allergies ?? const [],
        healthGoals: preferences.healthGoals ?? const [],
        cookingSkillLevel: () => preferences.cookingSkillLevel,
        timeAvailability: () => preferences.timeAvailability,
        dislikedFoods: preferences.dislikedFoods ?? const [],
        likedFoods: preferences.likedFoods ?? const [],
        householdSize: preferences.householdSize ?? state.householdSize,
        hideNutritionValues: hideNutritionValues,
        languageCode: () => languageCode,
        isHydrated: true,
      );
    } catch (_) {
      state = state.copyWith(
        languageCode: () => languageCode,
        hideNutritionValues: hideNutritionValues,
        isHydrated: true,
      );
    }
  }

  void toggleDietaryRestriction(String diet, bool selected) {
    final updated = List<String>.from(state.dietaryRestrictions);
    if (selected) {
      if (!updated.contains(diet)) {
        updated.add(diet);
      }
    } else {
      updated.remove(diet);
    }
    state = state.copyWith(dietaryRestrictions: updated);
  }

  void toggleAllergy(String allergy, bool selected) {
    final updated = List<String>.from(state.allergies);
    if (selected) {
      if (!updated.contains(allergy)) {
        updated.add(allergy);
      }
    } else {
      updated.remove(allergy);
    }
    state = state.copyWith(allergies: updated);
  }

  void toggleHealthGoal(String goal, bool selected) {
    final updated = List<String>.from(state.healthGoals);
    if (selected) {
      if (!updated.contains(goal)) {
        updated.add(goal);
      }
    } else {
      updated.remove(goal);
    }
    state = state.copyWith(healthGoals: updated);
  }

  void setCookingSkillLevel(String skill) {
    state = state.copyWith(cookingSkillLevel: () => skill);
  }

  void setTimeAvailability(String time) {
    state = state.copyWith(timeAvailability: () => time);
  }

  void setDislikedFoods(List<String> foods) {
    state = state.copyWith(dislikedFoods: foods);
  }

  void setLikedFoods(List<String> foods) {
    state = state.copyWith(likedFoods: foods);
  }

  void updateHouseholdSize(int size) {
    state = state.copyWith(householdSize: size);
  }

  void setHideNutritionValues(bool value) {
    state = state.copyWith(hideNutritionValues: value);
  }
}
