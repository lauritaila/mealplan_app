// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GoalsStep extends ConsumerWidget {
  const GoalsStep({super.key});

  final List<String> _goalOptions = const [
    'Weight Loss',
    'Weight Gain',
    'Muscle Building',
    'Heart Health',
    'Diabetes Management',
    'High Protein',
    'Low Sodium',
    'Anti-Inflammatory',
  ];

  String _goalLabel(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'Weight Loss':
        return l10n.goalWeightLoss;
      case 'Weight Gain':
        return l10n.goalWeightGain;
      case 'Muscle Building':
        return l10n.goalMuscleBuilding;
      case 'Heart Health':
        return l10n.goalHeartHealth;
      case 'Diabetes Management':
        return l10n.goalDiabetesManagement;
      case 'High Protein':
        return l10n.goalHighProtein;
      case 'Low Sodium':
        return l10n.goalLowSodium;
      case 'Anti-Inflammatory':
        return l10n.goalAntiInflammatory;
      default:
        return goal;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoals = ref.watch(preferencesWizardProvider).healthGoals;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.goalsTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: _goalOptions.map((goal) {
              final isSelected = selectedGoals.contains(goal);
              return FilterChip(
                label: Text(_goalLabel(l10n, goal)),
                selected: isSelected,
                onSelected: (selected) {
                  final currentSelection = List<String>.from(selectedGoals);
                  if (selected) {
                    currentSelection.add(goal);
                  } else {
                    currentSelection.remove(goal);
                  }
                  ref
                      .read(preferencesWizardProvider.notifier)
                      .updateHealthGoals(currentSelection);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
