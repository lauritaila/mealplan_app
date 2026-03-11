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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
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
    final authState = ref.watch(authProvider);
    final preferencesState = ref.watch(preferencesDetailsProvider);
    final preferencesNotifier = ref.read(preferencesDetailsProvider.notifier);
    final configAsync = ref.watch(preferences.preferencesConfigurationProvider);
    final localeCode = Localizations.localeOf(context).languageCode;
    final effectiveLanguageCode = preferencesState.languageCode ?? localeCode;

    final primaryGreen = theme.colorScheme.primary;
    final darkText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurfaceVariant;
    final cardBg = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.profilePreferencesTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // Hide Nutrition Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, color: primaryGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.profileHideNutritionLabel,
                                style: TextStyle(fontWeight: FontWeight.w600, color: darkText),
                              ),
                            ),
                            Switch(
                              value: preferencesState.hideNutritionValues,
                              onChanged: preferencesNotifier.setHideNutritionValues,
                              thumbColor: WidgetStateProperty.all(primaryGreen),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dietary Goals
                      _buildSectionHeader(Icons.track_changes_outlined, l10n.goalsTitle),
                      const SizedBox(height: 12),
                      _buildChipWrap(
                        options: goalOptions,
                        selectedOptions: preferencesState.healthGoals,
                        onToggle: preferencesNotifier.toggleHealthGoal,
                        labelMapper: (opt) => _localizedOption(config.goalOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: primaryGreen,
                      ),
                      const SizedBox(height: 32),

                      // Dietary Preferences
                      _buildSectionHeader(Icons.restaurant_menu_outlined, l10n.profileDietarySpecsLabel),
                      const SizedBox(height: 12),
                      _buildChipWrap(
                        options: dietOptions,
                        selectedOptions: preferencesState.dietaryRestrictions,
                        onToggle: preferencesNotifier.toggleDietaryRestriction,
                        labelMapper: (opt) => _localizedOption(config.dietaryOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: primaryGreen,
                        // hasAdd: true,
                      ),
                      const SizedBox(height: 32),

                      // Allergies
                      _buildSectionHeader(Icons.warning_amber_outlined, l10n.allergiesTitle),
                      const SizedBox(height: 12),
                      _buildChipWrap(
                        options: allergyOptions,
                        selectedOptions: preferencesState.allergies,
                        onToggle: preferencesNotifier.toggleAllergy,
                        labelMapper: (opt) => _localizedOption(config.allergyOptionLabels, effectiveLanguageCode, opt),
                        primaryColor: const Color(0xFF718371), // Slightly different green or same
                      ),
                      const SizedBox(height: 32),

                      // Cooking Details Card
                      _buildSectionCard(
                        icon: Icons.soup_kitchen_outlined,
                        title: l10n.cookingDetailsTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.cookingSkillTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkText)),
                            const SizedBox(height: 12),
                            _buildChoiceWrap(
                              options: skillLevels,
                              selected: preferencesState.cookingSkillLevel,
                              onSelected: preferencesNotifier.setCookingSkillLevel,
                              labelMapper: (opt) => _localizedOption(config.cookingOptionLabels, effectiveLanguageCode, opt),
                              primaryColor: primaryGreen,
                            ),
                            const SizedBox(height: 24),
                            Text(l10n.timeAvailabilityTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkText)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: theme.colorScheme.primaryContainer,
                                      inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                                      thumbColor: primaryGreen,
                                      trackHeight: 8,
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
                                const SizedBox(width: 12),
                                Text(
                                  _localizedOption(config.cookingOptionLabels, effectiveLanguageCode, preferencesState.timeAvailability ?? timeOptions.first),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_localizedOption(config.cookingOptionLabels, effectiveLanguageCode, timeOptions.first), style: const TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                                Text(_localizedOption(config.cookingOptionLabels, effectiveLanguageCode, timeOptions.last), style: const TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Household Size Card
                      _buildSectionCard(
                        icon: Icons.groups_outlined,
                        title: l10n.householdSizeTitle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircleButton(Icons.remove, () {
                              if (preferencesState.householdSize > minHousehold) {
                                preferencesNotifier.updateHouseholdSize(preferencesState.householdSize - 1);
                              }
                            }),
                            Column(
                              children: [
                                Text(
                                  preferencesState.householdSize.toString(),
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkText),
                                ),
                                Text(l10n.peopleLabel, style: TextStyle(fontSize: 12, color: secondaryText)),
                              ],
                            ),
                            _buildCircleButton(Icons.add, () {
                              if (preferencesState.householdSize < maxHousehold) {
                                preferencesNotifier.updateHouseholdSize(preferencesState.householdSize + 1);
                              }
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Food Preferences
                      _buildFoodPrefField(Icons.favorite, Colors.green, l10n.likedFoodsLabel, _likedController, l10n.likedFoodsHint, (val) => _updateFoodPreferences(preferencesNotifier)),
                      const SizedBox(height: 24),
                      _buildFoodPrefField(Icons.favorite, Colors.red, l10n.dislikedFoodsLabel, _dislikedController, l10n.dislikedFoodsHint, (val) => _updateFoodPreferences(preferencesNotifier)),
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
                  child: FilledButton.icon(
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
                      } catch (e) {
                         // Fallback error handling simplified
                        if (!context.mounted) return;
                        CustomSnackbar.showInfo(context, e.toString());
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      l10n.profileSavePreferences,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
        ],
      );
    });
  }

  Widget _buildChipWrap({
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String, bool) onToggle,
    required String Function(String) labelMapper,
    required Color primaryColor,
    bool hasAdd = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: [
          ...options.map((opt) {
            final isSelected = selectedOptions.contains(opt);
            return GestureDetector(
              onTap: () => onToggle(opt, !isSelected),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) const Icon(Icons.check, size: 14, color: Colors.white),
                    if (isSelected) const SizedBox(width: 4),
                    Text(
                      labelMapper(opt),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (hasAdd)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.outline, style: BorderStyle.none), // Mock add
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).addLabel,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceWrap({
    required List<String> options,
    required String? selected,
    required Function(String) onSelected,
    required String Function(String) labelMapper,
    required Color primaryColor,
  }) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelMapper(opt),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
      );
    });
  }

  Widget _buildFoodPrefField(IconData icon, Color iconColor, String title, TextEditingController controller, String hint, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
