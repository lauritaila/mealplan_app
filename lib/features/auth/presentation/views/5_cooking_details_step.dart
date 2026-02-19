// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class CookingDetailsStep extends ConsumerWidget {
  const CookingDetailsStep({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(preferencesConfigurationProvider);
    final state = ref.watch(preferencesWizardProvider);
    final notifier = ref.read(preferencesWizardProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.genericError)),
      data: (config) {
        final skillLevels = config.skillLevels;
        final timeOptions = config.timeOptions;
        final minSize = config.householdSize.min;
        final maxSize = config.householdSize.max;
        final cookingTitle = _localizedTitle(
          config.cookingTitles,
          localeCode,
          l10n.cookingDetailsTitle,
        );
        final cookingSkillTitle = _localizedTitle(
          config.cookingSkillTitles,
          localeCode,
          l10n.cookingSkillTitle,
        );
        final cookingTimeTitle = _localizedTitle(
          config.cookingTimeTitles,
          localeCode,
          l10n.timeAvailabilityTitle,
        );
        final householdTitle = _localizedTitle(
          config.cookingHouseholdTitles,
          localeCode,
          l10n.householdSizeTitle,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(
                Icons.soup_kitchen_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                cookingTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Text(cookingSkillTitle, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                alignment: WrapAlignment.center,
                children: skillLevels.map((level) {
                  return ChoiceChip(
                    label: Text(
                      _localizedOption(
                        config.cookingOptionLabels,
                        localeCode,
                        level,
                      ),
                    ),
                    selected: state.cookingSkillLevel == level,
                    onSelected: (_) => notifier.updateCookingSkillLevel(level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Text(cookingTimeTitle, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                alignment: WrapAlignment.center,
                children: timeOptions.map((time) {
                  return ChoiceChip(
                    label: Text(
                      _localizedOption(
                        config.cookingOptionLabels,
                        localeCode,
                        time,
                      ),
                    ),
                    selected: state.timeAvailability == time,
                    onSelected: (_) => notifier.updateTimeAvailability(time),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              Text(householdTitle, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: state.householdSize > minSize
                        ? () => notifier.updateHouseholdSize(
                            state.householdSize - 1,
                          )
                        : null,
                  ),
                  Text(
                    state.householdSize.toString(),
                    style: textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: state.householdSize < maxSize
                        ? () => notifier.updateHouseholdSize(
                            state.householdSize + 1,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
