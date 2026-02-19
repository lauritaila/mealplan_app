import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/preferences/domain/domain.dart';

class PreferencesConfigurationMapper {
  static PreferencesConfiguration fromRow(Map<String, dynamic> row) {
    final config = _toMap(row['configuration']);
    if (config.isEmpty) {
      throw const ConfigAppError.invalid('configuration');
    }

    final dietary = _toMap(config['dietaryPreferences']);
    final allergies = _toMap(config['allergies']);
    final healthGoals = _toMap(config['healthGoals']);
    final cookingDetails = _toMap(config['cookingDetails']);
    final householdSize = _toMap(cookingDetails['householdSize']);
    final ui = _toMap(config['ui']);
    final textFields = _toMap(ui['textFields']);
    final dietaryLabels = _toMap(dietary['labels']);
    final allergyLabels = _toMap(allergies['labels']);
    final goalLabels = _toMap(healthGoals['labels']);
    final cookingLabels = _toMap(cookingDetails['labels']);
    final foodLabels = _toMap(
      config['foodPreferences'],
    ).map((key, value) => MapEntry(key, value));
    final foodLabelsMap = _toMap(foodLabels['labels']);

    return PreferencesConfiguration(
      dietOptions: _stringList(dietary['dietOptions']),
      allergyOptions: _stringList(allergies['allergyOptions']),
      goalOptions: _stringList(healthGoals['goalOptions']),
      skillLevels: _stringList(cookingDetails['skillLevels']),
      timeOptions: _stringList(cookingDetails['timeOptions']),
      householdSize: HouseholdSizeConfig(
        min: _toInt(householdSize['min'], 1),
        max: _toInt(householdSize['max'], 10),
        defaultValue: _toInt(householdSize['default'], 1),
      ),
      textFields: UiTextFieldsConfig(
        allergiesOther: _toBool(textFields['allergiesOther'], true),
        foodPreferencesDisliked: _toBool(
          textFields['foodPreferencesDisliked'],
          true,
        ),
        foodPreferencesLiked: _toBool(textFields['foodPreferencesLiked'], true),
      ),
      dietaryTitles: _localizedValueMap(dietaryLabels, 'title'),
      dietaryOptionLabels: _localizedOptionsMap(dietaryLabels),
      allergyTitles: _localizedValueMap(allergyLabels, 'title'),
      allergyOptionLabels: _localizedOptionsMap(allergyLabels),
      allergyOtherTitles: _localizedValueMap(allergyLabels, 'otherTitle'),
      allergyOtherHints: _localizedValueMap(allergyLabels, 'otherHint'),
      goalTitles: _localizedValueMap(goalLabels, 'title'),
      goalOptionLabels: _localizedOptionsMap(goalLabels),
      cookingTitles: _localizedValueMap(cookingLabels, 'title'),
      cookingSkillTitles: _localizedValueMap(cookingLabels, 'skillTitle'),
      cookingTimeTitles: _localizedValueMap(cookingLabels, 'timeTitle'),
      cookingHouseholdTitles: _localizedValueMap(
        cookingLabels,
        'householdTitle',
      ),
      cookingOptionLabels: _localizedOptionsMap(cookingLabels),
      foodPreferencesTitles: _localizedValueMap(foodLabelsMap, 'title'),
      foodPreferencesLikedTitles: _localizedValueMap(
        foodLabelsMap,
        'likedTitle',
      ),
      foodPreferencesLikedHints: _localizedValueMap(foodLabelsMap, 'likedHint'),
      foodPreferencesDislikedTitles: _localizedValueMap(
        foodLabelsMap,
        'dislikedTitle',
      ),
      foodPreferencesDislikedHints: _localizedValueMap(
        foodLabelsMap,
        'dislikedHint',
      ),
    );
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static bool _toBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    return fallback;
  }

  static Map<String, String> _localizedValueMap(
    Map<String, dynamic> labels,
    String key,
  ) {
    final result = <String, String>{};
    labels.forEach((locale, raw) {
      final localeMap = _toMap(raw);
      final value = localeMap[key];
      if (value != null) {
        result[locale] = value.toString();
      }
    });
    return result;
  }

  static Map<String, Map<String, String>> _localizedOptionsMap(
    Map<String, dynamic> labels,
  ) {
    final result = <String, Map<String, String>>{};
    labels.forEach((locale, raw) {
      final localeMap = _toMap(raw);
      final options = _toMap(localeMap['options']);
      if (options.isNotEmpty) {
        result[locale] = options.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    });
    return result;
  }
}
