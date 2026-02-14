// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class AllergiesStep extends ConsumerStatefulWidget {
  const AllergiesStep({super.key});

  @override
  ConsumerState<AllergiesStep> createState() => _AllergiesStepState();
}

class _AllergiesStepState extends ConsumerState<AllergiesStep> {
  late final TextEditingController _customAllergyController;

  @override
  void initState() {
    super.initState();
    final customAllergy =
        ref.read(preferencesWizardProvider).customAllergy ?? '';
    _customAllergyController = TextEditingController(text: customAllergy);
  }

  @override
  void dispose() {
    _customAllergyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AllergiesStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final customAllergy =
        ref.read(preferencesWizardProvider).customAllergy ?? '';
    if (_customAllergyController.text != customAllergy) {
      _customAllergyController.text = customAllergy;
    }
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

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(preferencesConfigurationProvider);
    final selectedAllergies = ref.watch(preferencesWizardProvider).allergies;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (config) {
        final allergyOptions = config.allergyOptions;
        final showOther = config.textFields.allergiesOther;
        final allergiesTitle = _localizedTitle(
          config.allergyTitles,
          localeCode,
          l10n.allergiesTitle,
        );
        final otherTitle = _localizedTitle(
          config.allergyOtherTitles,
          localeCode,
          l10n.allergiesOtherTitle,
        );
        final otherHint = _localizedTitle(
          config.allergyOtherHints,
          localeCode,
          l10n.allergiesOtherHint,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                allergiesTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: allergyOptions.map((allergy) {
                  final isSelected = selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(
                      _localizedOption(
                        config.allergyOptionLabels,
                        localeCode,
                        allergy,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      final currentSelection = List<String>.from(
                        selectedAllergies,
                      );
                      if (selected) {
                        currentSelection.add(allergy);
                      } else {
                        currentSelection.remove(allergy);
                      }
                      ref
                          .read(preferencesWizardProvider.notifier)
                          .updateAllergies(currentSelection);
                    },
                  );
                }).toList(),
              ),
              if (showOther) ...[
                const SizedBox(height: 24),
                Text(otherTitle, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customAllergyController,
                  decoration: InputDecoration(
                    hintText: otherHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    ref
                        .read(preferencesWizardProvider.notifier)
                        .updateCustomAllergy(value);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
