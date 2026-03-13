// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class GoalsStep extends ConsumerWidget {
  const GoalsStep({super.key});

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
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.genericError)),
      data: (config) {
        final goalOptions = config.goalOptions;
        
        return Column(
          children: [
            AuthHeader(
              title: l10n.goalsTitle,
              subtitle: l10n.goalsSubtitle,
              icon: Icons.flag_rounded,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.start,
              children: goalOptions.map((goal) {
                final isSelected = selectedGoals.contains(goal);
                return FilterChip(
                  label: Text(
                    _localizedOption(
                      config.goalOptionLabels,
                      localeCode,
                      goal,
                    ),
                    style: TextStyle(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
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
