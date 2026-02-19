import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/preferences_details_provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_repository_provider.dart';
import 'package:meal_plan_app/features/preferences/presentation/providers/preferences_repository_provider.dart';
import 'package:meal_plan_app/features/preferences/presentation/providers/preferences_configuration_provider.dart'
    as preferences;
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class PreferencesDetailsScreen extends ConsumerStatefulWidget {
  const PreferencesDetailsScreen({super.key});

  @override
  ConsumerState<PreferencesDetailsScreen> createState() =>
      _PreferencesDetailsScreenState();
}

class _PreferencesDetailsScreenState
    extends ConsumerState<PreferencesDetailsScreen> {
  late final TextEditingController _dislikedController;
  late final TextEditingController _likedController;
  bool _controllersHydrated = false;

  @override
  void initState() {
    super.initState();
    _dislikedController = TextEditingController();
    _likedController = TextEditingController();
    Future.microtask(() async {
      await ref.read(preferencesDetailsProvider.notifier).hydrateFromServer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _controllersHydrated) return;
        final hydrated = ref.read(preferencesDetailsProvider);
        if (hydrated.isHydrated) {
          if (_dislikedController.text.isEmpty) {
            _dislikedController.text = hydrated.dislikedFoods.join(', ');
          }
          if (_likedController.text.isEmpty) {
            _likedController.text = hydrated.likedFoods.join(', ');
          }
          _controllersHydrated = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _dislikedController.dispose();
    _likedController.dispose();
    super.dispose();
  }

  String _localizedTitle(
    Map<String, String> titles,
    String locale,
    String fallback,
  ) {
    return titles[locale] ?? titles['en'] ?? fallback;
  }

  String _localizedOption(
    Map<String, Map<String, String>> labels,
    String locale,
    String key,
  ) {
    final map = labels[locale] ?? labels['en'] ?? const {};
    return map[key] ?? key;
  }

  void _updateFoodPreferences(PreferencesDetails preferencesNotifier) {
    final disliked = _dislikedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final liked = _likedController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    preferencesNotifier.setDislikedFoods(disliked);
    preferencesNotifier.setLikedFoods(liked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final preferencesState = ref.watch(preferencesDetailsProvider);
    final preferencesNotifier = ref.read(preferencesDetailsProvider.notifier);
    final configAsync = ref.watch(preferences.preferencesConfigurationProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    final effectiveLanguageCode = preferencesState.languageCode ?? localeCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePreferencesTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: configAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(error.toString()),
          ),
          data: (config) {
            final dietOptions = config.dietOptions;
            final allergyOptions = config.allergyOptions;
            final goalOptions = config.goalOptions;
            final skillLevels = config.skillLevels;
            final timeOptions = config.timeOptions;
            final minHousehold = config.householdSize.min;
            final maxHousehold = config.householdSize.max;
            final showDisliked = config.textFields.foodPreferencesDisliked;
            final showLiked = config.textFields.foodPreferencesLiked;
            final dietaryTitle = _localizedTitle(
              config.dietaryTitles,
              effectiveLanguageCode,
              l10n.profileDietarySpecsLabel,
            );
            final allergiesTitle = _localizedTitle(
              config.allergyTitles,
              effectiveLanguageCode,
              l10n.allergiesTitle,
            );
            final goalsTitle = _localizedTitle(
              config.goalTitles,
              effectiveLanguageCode,
              l10n.goalsTitle,
            );
            final cookingTitle = _localizedTitle(
              config.cookingTitles,
              effectiveLanguageCode,
              l10n.cookingDetailsTitle,
            );
            final cookingSkillTitle = _localizedTitle(
              config.cookingSkillTitles,
              effectiveLanguageCode,
              l10n.cookingSkillTitle,
            );
            final cookingTimeTitle = _localizedTitle(
              config.cookingTimeTitles,
              effectiveLanguageCode,
              l10n.timeAvailabilityTitle,
            );
            final cookingHouseholdTitle = _localizedTitle(
              config.cookingHouseholdTitles,
              effectiveLanguageCode,
              l10n.householdSizeTitle,
            );
            final foodPreferencesTitle = _localizedTitle(
              config.foodPreferencesTitles,
              effectiveLanguageCode,
              l10n.foodPreferencesTitle,
            );
            final dislikedTitle = _localizedTitle(
              config.foodPreferencesDislikedTitles,
              effectiveLanguageCode,
              l10n.dislikedFoodsTitle,
            );
            final dislikedHint = _localizedTitle(
              config.foodPreferencesDislikedHints,
              effectiveLanguageCode,
              l10n.dislikedFoodsHint,
            );
            final likedTitle = _localizedTitle(
              config.foodPreferencesLikedTitles,
              effectiveLanguageCode,
              l10n.likedFoodsTitle,
            );
            final likedHint = _localizedTitle(
              config.foodPreferencesLikedHints,
              effectiveLanguageCode,
              l10n.likedFoodsHint,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.profileHideNutritionLabel),
                      value: preferencesState.hideNutritionValues,
                      onChanged: preferencesNotifier.setHideNutritionValues,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dietaryTitle, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: dietOptions.map((diet) {
                              final isSelected = preferencesState
                                  .dietaryRestrictions
                                  .contains(diet);
                              return FilterChip(
                                label: Text(
                                  _localizedOption(
                                    config.dietaryOptionLabels,
                                    effectiveLanguageCode,
                                    diet,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  preferencesNotifier.toggleDietaryRestriction(
                                    diet,
                                    selected,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allergiesTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: allergyOptions.map((allergy) {
                              final isSelected = preferencesState.allergies
                                  .contains(allergy);
                              return FilterChip(
                                label: Text(
                                  _localizedOption(
                                    config.allergyOptionLabels,
                                    effectiveLanguageCode,
                                    allergy,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  preferencesNotifier.toggleAllergy(
                                    allergy,
                                    selected,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goalsTitle, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: goalOptions.map((goal) {
                              final isSelected = preferencesState.healthGoals
                                  .contains(goal);
                              return FilterChip(
                                label: Text(
                                  _localizedOption(
                                    config.goalOptionLabels,
                                    effectiveLanguageCode,
                                    goal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  preferencesNotifier.toggleHealthGoal(
                                    goal,
                                    selected,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cookingTitle, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 12),
                          Text(
                            cookingSkillTitle,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: skillLevels.map((level) {
                              return ChoiceChip(
                                label: Text(
                                  _localizedOption(
                                    config.cookingOptionLabels,
                                    effectiveLanguageCode,
                                    level,
                                  ),
                                ),
                                selected:
                                    preferencesState.cookingSkillLevel == level,
                                onSelected: (_) {
                                  preferencesNotifier.setCookingSkillLevel(
                                    level,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cookingTimeTitle,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: timeOptions.map((time) {
                              return ChoiceChip(
                                label: Text(
                                  _localizedOption(
                                    config.cookingOptionLabels,
                                    effectiveLanguageCode,
                                    time,
                                  ),
                                ),
                                selected:
                                    preferencesState.timeAvailability == time,
                                onSelected: (_) {
                                  preferencesNotifier.setTimeAvailability(time);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cookingHouseholdTitle,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed:
                                    preferencesState.householdSize >
                                        minHousehold
                                    ? () => preferencesNotifier
                                          .updateHouseholdSize(
                                            preferencesState.householdSize - 1,
                                          )
                                    : null,
                              ),
                              Text(
                                preferencesState.householdSize.toString(),
                                style: theme.textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed:
                                    preferencesState.householdSize <
                                        maxHousehold
                                    ? () => preferencesNotifier
                                          .updateHouseholdSize(
                                            preferencesState.householdSize + 1,
                                          )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodPreferencesTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          if (showDisliked) ...[
                            Text(
                              dislikedTitle,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dislikedController,
                              decoration: InputDecoration(
                                hintText: dislikedHint,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onEditingComplete: () =>
                                  _updateFoodPreferences(preferencesNotifier),
                            ),
                          ],
                          if (showDisliked && showLiked)
                            const SizedBox(height: 16),
                          if (showLiked) ...[
                            Text(likedTitle, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _likedController,
                              decoration: InputDecoration(
                                hintText: likedHint,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onEditingComplete: () =>
                                  _updateFoodPreferences(preferencesNotifier),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final auth = authState;
                      if (auth is! AuthenticatedAuthState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.errorMealPlanNotAuthenticated),
                          ),
                        );
                        return;
                      }
                      try {
                        _updateFoodPreferences(preferencesNotifier);
                        final updatedPreferencesState = ref.read(
                          preferencesDetailsProvider,
                        );
                        final repository = ref.read(
                          preferencesRepositoryProvider,
                        );
                        final profileRepository = ref.read(
                          profileRepositoryProvider,
                        );
                        final userPreferences = updatedPreferencesState
                            .toUserPreferences(auth.user.id);
                        // Save previous state for rollback if needed
                        final previousPreferences = await repository
                            .fetchUserPreference();
                        try {
                          await repository.saveUserPreference(userPreferences);
                          await profileRepository.updateHideNutritionValues(
                            updatedPreferencesState.hideNutritionValues,
                          );
                          await ref
                              .read(authProvider.notifier)
                              .refreshUserStatus();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.preferencesSaved)),
                          );
                        } catch (e) {
                          // Attempt rollback if first call succeeded but second failed
                          Object? rollbackError;
                          if (previousPreferences != null) {
                            try {
                              await repository.saveUserPreference(
                                previousPreferences,
                              );
                            } catch (rollback) {
                              rollbackError = rollback;
                              // Log rollback error
                              debugPrint('Rollback failed: $rollback');
                            }
                          }
                          if (!context.mounted) return;
                          String message = e is AppError
                              ? localizeErrorCode(
                                  l10n,
                                  e.code,
                                  fallback: e.message,
                                )
                              : e.toString();
                          if (rollbackError != null) {
                            String rollbackMsg = rollbackError is AppError
                                ? localizeErrorCode(
                                    l10n,
                                    rollbackError.code,
                                    fallback: rollbackError.message,
                                  )
                                : rollbackError.toString();
                            message =
                                'Failed to save preferences and rollback also failed. The app may be in an inconsistent state.\n$message\nRollback error: $rollbackMsg';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        String message = e.toString();
                        if (e is AppError) {
                          message = localizeErrorCode(
                            l10n,
                            e.code,
                            fallback: e.message,
                          );
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
                    child: Text(l10n.profileSavePreferences),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
