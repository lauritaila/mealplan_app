// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DietaryStep extends ConsumerWidget {
  const DietaryStep({super.key});

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
    final selectedDiets = ref.watch(preferencesWizardProvider).dietaryRestrictions;
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.errorLoadingConfiguration)),
      data: (config) {
        final dietOptions = config.dietOptions;
        
        return Column(
          children: [
            AuthHeader(
              title: l10n.dietaryTitle,
              subtitle: l10n.dietarySubtitle,
              icon: Icons.eco_rounded,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.start,
              children: dietOptions.map((diet) {
                final isSelected = selectedDiets.contains(diet);
                return FilterChip(
                  label: Text(
                    _localizedOption(
                      config.dietaryOptionLabels,
                      localeCode,
                      diet,
                    ),
                    style: TextStyle(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  backgroundColor: colors.surface,
                  selectedColor: colors.primary,
                  checkmarkColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? colors.primary : colors.outlineVariant,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
