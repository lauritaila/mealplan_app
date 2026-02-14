class HouseholdSizeConfig {
  final int min;
  final int max;
  final int defaultValue;

  const HouseholdSizeConfig({
    required this.min,
    required this.max,
    required this.defaultValue,
  });
}

class UiTextFieldsConfig {
  final bool allergiesOther;
  final bool foodPreferencesDisliked;
  final bool foodPreferencesLiked;

  const UiTextFieldsConfig({
    required this.allergiesOther,
    required this.foodPreferencesDisliked,
    required this.foodPreferencesLiked,
  });
}

class PreferencesConfiguration {
  final List<String> dietOptions;
  final List<String> allergyOptions;
  final List<String> goalOptions;
  final List<String> skillLevels;
  final List<String> timeOptions;
  final HouseholdSizeConfig householdSize;
  final UiTextFieldsConfig textFields;
  final Map<String, String> dietaryTitles;
  final Map<String, Map<String, String>> dietaryOptionLabels;
  final Map<String, String> allergyTitles;
  final Map<String, Map<String, String>> allergyOptionLabels;
  final Map<String, String> allergyOtherTitles;
  final Map<String, String> allergyOtherHints;
  final Map<String, String> goalTitles;
  final Map<String, Map<String, String>> goalOptionLabels;
  final Map<String, String> cookingTitles;
  final Map<String, String> cookingSkillTitles;
  final Map<String, String> cookingTimeTitles;
  final Map<String, String> cookingHouseholdTitles;
  final Map<String, Map<String, String>> cookingOptionLabels;
  final Map<String, String> foodPreferencesTitles;
  final Map<String, String> foodPreferencesLikedTitles;
  final Map<String, String> foodPreferencesLikedHints;
  final Map<String, String> foodPreferencesDislikedTitles;
  final Map<String, String> foodPreferencesDislikedHints;

  const PreferencesConfiguration({
    required this.dietOptions,
    required this.allergyOptions,
    required this.goalOptions,
    required this.skillLevels,
    required this.timeOptions,
    required this.householdSize,
    required this.textFields,
    required this.dietaryTitles,
    required this.dietaryOptionLabels,
    required this.allergyTitles,
    required this.allergyOptionLabels,
    required this.allergyOtherTitles,
    required this.allergyOtherHints,
    required this.goalTitles,
    required this.goalOptionLabels,
    required this.cookingTitles,
    required this.cookingSkillTitles,
    required this.cookingTimeTitles,
    required this.cookingHouseholdTitles,
    required this.cookingOptionLabels,
    required this.foodPreferencesTitles,
    required this.foodPreferencesLikedTitles,
    required this.foodPreferencesLikedHints,
    required this.foodPreferencesDislikedTitles,
    required this.foodPreferencesDislikedHints,
  });

  static PreferencesConfiguration empty() {
    return const PreferencesConfiguration(
      dietOptions: [],
      allergyOptions: [],
      goalOptions: [],
      skillLevels: [],
      timeOptions: [],
      householdSize: HouseholdSizeConfig(min: 1, max: 10, defaultValue: 1),
      textFields: UiTextFieldsConfig(
        allergiesOther: true,
        foodPreferencesDisliked: true,
        foodPreferencesLiked: true,
      ),
      dietaryTitles: {},
      dietaryOptionLabels: {},
      allergyTitles: {},
      allergyOptionLabels: {},
      allergyOtherTitles: {},
      allergyOtherHints: {},
      goalTitles: {},
      goalOptionLabels: {},
      cookingTitles: {},
      cookingSkillTitles: {},
      cookingTimeTitles: {},
      cookingHouseholdTitles: {},
      cookingOptionLabels: {},
      foodPreferencesTitles: {},
      foodPreferencesLikedTitles: {},
      foodPreferencesLikedHints: {},
      foodPreferencesDislikedTitles: {},
      foodPreferencesDislikedHints: {},
    );
  }
}

