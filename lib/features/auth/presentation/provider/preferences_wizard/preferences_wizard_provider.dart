// preferences_wizard_provider.dart

import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'preferences_wizard_state.dart';

part 'preferences_wizard_provider.g.dart';

@riverpod
class PreferencesWizard extends _$PreferencesWizard {
  @override
  PreferencesWizardState build() {
    return PreferencesWizardState();
  }

  void nextStep() {
    state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void updateDietaryRestrictions(List<String> restrictions) {
    state = state.copyWith(dietaryRestrictions: restrictions);
  }

  void updateAllergies(List<String> allergies) {
    state = state.copyWith(allergies: allergies);
  }

  void updatePreferredCuisines(List<String> cuisines) {
    state = state.copyWith(preferredCuisines: cuisines);
  }

  void updateHealthGoals(List<String> goals) {
    state = state.copyWith(healthGoals: goals);
  }

  void updateCookingSkillLevel(String skill) {
    state = state.copyWith(cookingSkillLevel: skill);
  }

  void updateTimeAvailability(String time) {
    state = state.copyWith(timeAvailability: time);
  }

  void updateDislikedFoods(List<String> foods) {
    state = state.copyWith(dislikedFoods: foods);
  }

  void updateLikedFoods(List<String> foods) {
    state = state.copyWith(likedFoods: foods);
  }

  void updateHouseholdSize(int size) {
    state = state.copyWith(householdSize: size);
  }

  Future<void> submitPreferences() async {
    state = state.copyWith(formStatus: FormStatus.submitting);

    try {
      final authState = ref.read(authProvider);
      if (authState is! AuthenticatedAuthState) {
        throw const PermissionAppError.unauthorized();
      }

      final userId = authState.user.id;
      final authRepository = ref.read(authRepositoryProvider);

      final userPreferences = state.toUserPreferences(userId);

      await authRepository.saveUserPreference(userPreferences, userId);

      state = state.copyWith(formStatus: FormStatus.success);

      ref.read(authProvider.notifier).markOnboardingComplete();

      await ref.read(authProvider.notifier).refreshUserStatus();
    } catch (e) {
      String? errorCode;
      String? errorMessage;
      if (e is AppError) {
        errorCode = e.code;
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      state = state.copyWith(
        formStatus: FormStatus.error,
        errorCode: errorCode,
        errorMessage: errorMessage,
      );
    }
  }
}
