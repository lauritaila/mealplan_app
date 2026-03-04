// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DietaryStep extends ConsumerWidget {
  const DietaryStep({super.key});

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
    final selectedDiets = ref
        .watch(preferencesWizardProvider)
        .dietaryRestrictions;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        debugPrint(
          'Dietary config error: '
          '${error.toString()}',
        );
        return Center(child: Text(l10n.errorLoadingConfiguration));
      },
      data: (config) {
        final dietOptions = config.dietOptions;
        final dietaryTitle = _localizedTitle(
          config.dietaryTitles,
          localeCode,
          l10n.dietaryTitle,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                dietaryTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: dietOptions.map((diet) {
                  final isSelected = selectedDiets.contains(diet);
                  return FilterChip(
                    label: Text(
                      _localizedOption(
                        config.dietaryOptionLabels,
                        localeCode,
                        diet,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      final currentSelection = List<String>.from(selectedDiets);
                      if (selected) {
                        currentSelection.add(diet);
                      } else {
                        currentSelection.remove(diet);
                      }
                      ref
                          .read(preferencesWizardProvider.notifier)
                          .updateDietaryRestrictions(currentSelection);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
