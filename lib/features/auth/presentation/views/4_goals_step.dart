// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GoalsStep extends ConsumerWidget {
  const GoalsStep({super.key});

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
    final selectedGoals = ref.watch(preferencesWizardProvider).healthGoals;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (config) {
        final goalOptions = config.goalOptions;
        final goalsTitle = _localizedTitle(
          config.goalTitles,
          localeCode,
          l10n.goalsTitle,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                goalsTitle,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                alignment: WrapAlignment.center,
                children: goalOptions.map((goal) {
                  final isSelected = selectedGoals.contains(goal);
                  return FilterChip(
                    label: Text(
                      _localizedOption(
                        config.goalOptionLabels,
                        localeCode,
                        goal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      final currentSelection =
                          List<String>.from(selectedGoals);
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
      },
    );
  }
}
