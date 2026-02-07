// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DietaryStep extends ConsumerWidget {
  const DietaryStep({super.key});

  final List<String> _dietOptions = const [
    'Vegetarian', 'Vegan', 'Pescatarian', 'Keto', 'Paleo', 'Mediterranean',
    'Low Carb', 'Low Fat', 'Gluten Free', 'Dairy Free', 'Nut Free', 'Halal', 'Kosher'
  ];

  String _dietLabel(AppLocalizations l10n, String diet) {
    switch (diet) {
      case 'Vegetarian':
        return l10n.dietVegetarian;
      case 'Vegan':
        return l10n.dietVegan;
      case 'Pescatarian':
        return l10n.dietPescatarian;
      case 'Keto':
        return l10n.dietKeto;
      case 'Paleo':
        return l10n.dietPaleo;
      case 'Mediterranean':
        return l10n.dietMediterranean;
      case 'Low Carb':
        return l10n.dietLowCarb;
      case 'Low Fat':
        return l10n.dietLowFat;
      case 'Gluten Free':
        return l10n.dietGlutenFree;
      case 'Dairy Free':
        return l10n.dietDairyFree;
      case 'Nut Free':
        return l10n.dietNutFree;
      case 'Halal':
        return l10n.dietHalal;
      case 'Kosher':
        return l10n.dietKosher;
      default:
        return diet;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDiets = ref.watch(preferencesWizardProvider).dietaryRestrictions;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.dietaryTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: _dietOptions.map((diet) {
              final isSelected = selectedDiets.contains(diet);
              return FilterChip(
                label: Text(_dietLabel(l10n, diet)),
                selected: isSelected,
                onSelected: (selected) {
                  final currentSelection = List<String>.from(selectedDiets);
                  if (selected) {
                    currentSelection.add(diet);
                  } else {
                    currentSelection.remove(diet);
                  }
                  ref.read(preferencesWizardProvider.notifier).updateDietaryRestrictions(currentSelection);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
