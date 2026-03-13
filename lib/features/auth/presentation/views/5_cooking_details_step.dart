// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class CookingDetailsStep extends ConsumerWidget {
  const CookingDetailsStep({super.key});

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
    final colors = Theme.of(context).colorScheme;
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

        return Column(
          children: [
            AuthHeader(
              title: l10n.cookingDetailsTitle,
              subtitle: l10n.cookingDetailsSubtitle,
              icon: Icons.soup_kitchen_rounded,
            ),
            const SizedBox(height: 32),
            
            _DetailsSection(
              title: l10n.cookingSkillTitle.toUpperCase(),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: skillLevels.map((level) {
                  final isSelected = state.cookingSkillLevel == level;
                  return ChoiceChip(
                    label: Text(
                      _localizedOption(config.cookingOptionLabels, localeCode, level),
                      style: TextStyle(
                        color: isSelected ? colors.onPrimary : colors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => notifier.updateCookingSkillLevel(level),
                    backgroundColor: colors.surface,
                    selectedColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.outlineVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _DetailsSection(
              title: l10n.timeAvailabilityTitle.toUpperCase(),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: timeOptions.map((time) {
                  final isSelected = state.timeAvailability == time;
                  return ChoiceChip(
                    label: Text(
                      _localizedOption(config.cookingOptionLabels, localeCode, time),
                      style: TextStyle(
                        color: isSelected ? colors.onPrimary : colors.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => notifier.updateTimeAvailability(time),
                    backgroundColor: colors.surface,
                    selectedColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.outlineVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            _DetailsSection(
              title: l10n.householdSizeTitle.toUpperCase(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: state.householdSize > minSize
                          ? () => notifier.updateHouseholdSize(state.householdSize - 1)
                          : null,
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          state.householdSize.toString(),
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          l10n.peopleLabel,
                          style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      onPressed: state.householdSize < maxSize
                          ? () => notifier.updateHouseholdSize(state.householdSize + 1)
                          : null,
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
