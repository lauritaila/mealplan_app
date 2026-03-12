import 'package:meal_plan_app/features/shared/shared.dart';
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
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
      var hydrationSucceeded = false;
      try {
        await ref.read(preferencesDetailsProvider.notifier).hydrateFromServer();
        hydrationSucceeded = true;
      } catch (e, stack) {
        debugPrint(
          '[PreferencesDetailsScreen] hydrateFromServer error: $e\n$stack',
        );
        ref.read(preferencesDetailsProvider.notifier).handleHydrationError(e);
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          final message = localizeErrorCode(
            l10n,
            e is AppError ? e.code : null,
            fallback: e is AppError ? e.message : null,
          );
          CustomSnackbar.showError(context, message);
        }
      }

      if (!hydrationSucceeded) {
        _controllersHydrated = false;
        return;
      }

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

  String _localizedOption(
    Map<String, Map<String, String>> labels,
    String locale,
    String key,
  ) {
    final map = labels[locale] ?? labels['en'] ?? const {};
    return map[key] ?? key;
  }

  void _updateFoodPreferences(dynamic notifier) {
    if (notifier is! PreferencesDetails) return;
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
    notifier.setDislikedFoods(disliked);
    notifier.setLikedFoods(liked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final authState = ref.watch(authProvider);
    final preferencesState = ref.watch(preferencesDetailsProvider);
    final preferencesNotifier = ref.read(preferencesDetailsProvider.notifier);
    final configAsync = ref.watch(preferences.preferencesConfigurationProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    final effectiveLanguageCode = preferencesState.languageCode ?? localeCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.profilePreferencesTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: configAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (config) {
          final dietOptions = config.dietOptions;
          final allergyOptions = config.allergyOptions;
          final goalOptions = config.goalOptions;
          final skillLevels = config.skillLevels;
          final timeOptions = config.timeOptions;
          final minHousehold = config.householdSize.min;
          final maxHousehold = config.householdSize.max;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hide Nutrition Card
                      GestureDetector(
                        onTap: () => preferencesNotifier.setHideNutritionValues(!preferencesState.hideNutritionValues),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: customColors.darkSage?.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.show_chart, color: customColors.darkSage, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  l10n.profileHideNutritionLabel,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: customColors.textDarkBlue,
                                  ),
                                ),
                              ),
                              Switch.adaptive(
                                value: preferencesState.hideNutritionValues,
                                onChanged: preferencesNotifier.setHideNutritionValues,
                                activeTrackColor: customColors.darkSage,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Dietary Goals
                      _buildSectionHeader(context, Icons.track_changes, l10n.goalsTitle),
                      const SizedBox(height: 16),
                      _buildChipWrap(
                        context: context,
                        options: goalOptions,
                        selectedOptions: preferencesState.healthGoals,
                        onToggle: preferencesNotifier.toggleHealthGoal,
                        labelMapper: (opt) => _localizedOption(config.goalOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: customColors.darkSage!,
                      ),
                      const SizedBox(height: 32),

                      // Dietary Preferences
                      _buildSectionHeader(context, Icons.restaurant, l10n.profileDietarySpecsLabel),
                      const SizedBox(height: 16),
                      _buildChipWrap(
                        context: context,
                        options: dietOptions,
                        selectedOptions: preferencesState.dietaryRestrictions,
                        onToggle: preferencesNotifier.toggleDietaryRestriction,
                        labelMapper: (opt) => _localizedOption(config.dietaryOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: customColors.darkSage!,
                      ),
                      const SizedBox(height: 32),

                      // Allergies
                      _buildSectionHeader(context, Icons.warning_amber, l10n.allergiesTitle),
                      const SizedBox(height: 16),
                      _buildChipWrap(
                        context: context,
                        options: allergyOptions,
                        selectedOptions: preferencesState.allergies,
                        onToggle: preferencesNotifier.toggleAllergy,
                        labelMapper: (opt) => _localizedOption(config.allergyOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: const Color(0xFFDC7353), // Standardized allergy color or darkSage
                      ),
                      const SizedBox(height: 32),

                      // Cooking Details Card
                      _buildSectionCard(
                        context: context,
                        icon: Icons.soup_kitchen,
                        title: l10n.cookingDetailsTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.cookingSkillTitle.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: customColors.slateGrey?.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildChoiceWrap(
                              context: context,
                              options: skillLevels,
                              selected: preferencesState.cookingSkillLevel,
                              onSelected: preferencesNotifier.setCookingSkillLevel,
                              labelMapper: (opt) => _localizedOption(config.cookingOptionLabels, effectiveLanguageCode, opt),
                              primaryColor: customColors.darkSage!,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.timeAvailabilityTitle.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: customColors.slateGrey?.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: customColors.darkSage,
                                      inactiveTrackColor: customColors.chartTabBackground,
                                      thumbColor: Colors.white,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 10,
                                        elevation: 4,
                                      ),
                                      trackHeight: 6,
                                      overlayShape: SliderComponentShape.noOverlay,
                                    ),
                                    child: Slider(
                                      value: timeOptions.indexOf(preferencesState.timeAvailability ?? timeOptions.first).toDouble().clamp(0, (timeOptions.length - 1).toDouble()),
                                      min: 0,
                                      max: (timeOptions.length - 1).toDouble(),
                                      onChanged: (val) {
                                        preferencesNotifier.setTimeAvailability(timeOptions[val.toInt()]);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: customColors.darkSage?.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _localizedOption(config.cookingOptionLabels, effectiveLanguageCode, preferencesState.timeAvailability ?? timeOptions.first),
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: customColors.darkSage,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Household Size Card
                      _buildSectionCard(
                        context: context,
                        icon: Icons.groups,
                        title: l10n.householdSizeTitle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircleButton(context, Icons.remove, () {
                              if (preferencesState.householdSize > minHousehold) {
                                preferencesNotifier.updateHouseholdSize(preferencesState.householdSize - 1);
                              }
                            }),
                            Column(
                              children: [
                                Text(
                                  preferencesState.householdSize.toString(),
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: customColors.textDarkBlue,
                                  ),
                                ),
                                Text(
                                  l10n.peopleCount(preferencesState.householdSize).split(' ').last,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: customColors.slateGrey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            _buildCircleButton(context, Icons.add, () {
                              if (preferencesState.householdSize < maxHousehold) {
                                preferencesNotifier.updateHouseholdSize(preferencesState.householdSize + 1);
                              }
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Food Preferences
                      _buildFoodPrefField(
                        context,
                        Icons.favorite,
                        customColors.darkSage!,
                        l10n.likedFoodsTitle,
                        _likedController,
                        l10n.likedFoodsHint,
                        (val) => _updateFoodPreferences(preferencesNotifier),
                      ),
                      const SizedBox(height: 24),
                      _buildFoodPrefField(
                        context,
                        Icons.heart_broken,
                        const Color(0xFFDC7353),
                        l10n.dislikedFoodsTitle,
                        _dislikedController,
                        l10n.dislikedFoodsHint,
                        (val) => _updateFoodPreferences(preferencesNotifier),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    onPressed: () async {
                      final auth = authState;
                      if (auth is! AuthenticatedAuthState) return;
                      _updateFoodPreferences(preferencesNotifier);
                      final updatedPreferencesState = ref.read(preferencesDetailsProvider);
                      final repository = ref.read(preferencesRepositoryProvider);
                      final profileRepository = ref.read(profileRepositoryProvider);
                      final userPreferences = updatedPreferencesState.toUserPreferences(auth.user.id);
                      try {
                        await repository.saveUserPreference(userPreferences);
                        await profileRepository.updateHideNutritionValues(updatedPreferencesState.hideNutritionValues);
                        await ref.read(authProvider.notifier).refreshUserStatus();
                        if (!context.mounted) return;
                        CustomSnackbar.showInfo(context, l10n.preferencesSaved);
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (!context.mounted) return;
                        CustomSnackbar.showInfo(context, e.toString());
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: customColors.darkSage,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    child: Text(
                      l10n.profileSavePreferences,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: customColors.darkSage),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildChipWrap({
    required BuildContext context,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String, bool) onToggle,
    required String Function(String) labelMapper,
    required Color primaryColor,
  }) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selectedOptions.contains(opt);
        return GestureDetector(
          onTap: () => onToggle(opt, !isSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
                if (isSelected) const SizedBox(width: 6),
                Text(
                  labelMapper(opt),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : customColors.textDarkBlue?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChoiceWrap({
    required BuildContext context,
    required List<String> options,
    required String? selected,
    required Function(String) onSelected,
    required String Function(String) labelMapper,
    required Color primaryColor,
  }) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : customColors.chartTabBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? primaryColor : customColors.slateGrey!.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              labelMapper(opt),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : customColors.textDarkBlue?.withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({required BuildContext context, required IconData icon, required String title, required Widget child}) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: customColors.darkSage),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCircleButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: customColors.chartTabBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: customColors.slateGrey!.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: customColors.textDarkBlue, size: 20),
      ),
    );
  }

  Widget _buildFoodPrefField(BuildContext context, IconData icon, Color iconColor, String title, TextEditingController controller, String hint, Function(String) onChanged) {
    final customColors = Theme.of(context).extension<AppCustomColors>()!;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: textTheme.bodyMedium?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: customColors.slateGrey?.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: customColors.chartTabBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: customColors.darkSage!, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
