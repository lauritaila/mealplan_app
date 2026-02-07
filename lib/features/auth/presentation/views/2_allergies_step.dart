// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/preferences_wizard/preferences_wizard_provider.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class AllergiesStep extends ConsumerWidget {
  const AllergiesStep({super.key});

  final List<String> _allergyOptions = const [
    'Nuts', 'Dairy', 'Eggs', 'Soy', 'Wheat', 'Fish', 'Shellfish', 'Sesame'
  ];

  String _allergyLabel(AppLocalizations l10n, String allergy) {
    switch (allergy) {
      case 'Nuts':
        return l10n.allergyNuts;
      case 'Dairy':
        return l10n.allergyDairy;
      case 'Eggs':
        return l10n.allergyEggs;
      case 'Soy':
        return l10n.allergySoy;
      case 'Wheat':
        return l10n.allergyWheat;
      case 'Fish':
        return l10n.allergyFish;
      case 'Shellfish':
        return l10n.allergyShellfish;
      case 'Sesame':
        return l10n.allergySesame;
      default:
        return allergy;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAllergies = ref.watch(preferencesWizardProvider).allergies;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.allergiesTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: _allergyOptions.map((allergy) {
              final isSelected = selectedAllergies.contains(allergy);
              return FilterChip(
                label: Text(_allergyLabel(l10n, allergy)),
                selected: isSelected,
                onSelected: (selected) {
                  final currentSelection = List<String>.from(selectedAllergies);
                  if (selected) {
                    currentSelection.add(allergy);
                  } else {
                    currentSelection.remove(allergy);
                  }
                  ref.read(preferencesWizardProvider.notifier).updateAllergies(currentSelection);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(l10n.allergiesOtherTitle, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: l10n.allergiesOtherHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            // You might want to handle this text field's state separately
            // or add an "Other" string to the list and show the field when selected.
          ),
        ],
      ),
    );
  }
}
