// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class AllergiesStep extends ConsumerStatefulWidget {
  const AllergiesStep({super.key});

  @override
  ConsumerState<AllergiesStep> createState() => _AllergiesStepState();
}

class _AllergiesStepState extends ConsumerState<AllergiesStep> {
  late final TextEditingController _customAllergyController;
  late final ProviderSubscription<String?> _customAllergySubscription;

  @override
  void initState() {
    super.initState();
    final customAllergy = ref.read(preferencesWizardProvider).customAllergy ?? '';
    _customAllergyController = TextEditingController(text: customAllergy);

    _customAllergySubscription = ref.listenManual<String?>(
      preferencesWizardProvider.select((s) => s.customAllergy),
      (previous, next) {
        final newValue = next ?? '';
        if (_customAllergyController.text != newValue) {
          _customAllergyController.text = newValue;
        }
      },
    );
  }

  @override
  void dispose() {
    _customAllergySubscription.close();
    _customAllergyController.dispose();
    super.dispose();
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.errorLoadingConfiguration)),
      data: (config) {
        final allergyOptions = config.allergyOptions;
        final showOther = config.textFields.allergiesOther;

        return Column(
          children: [
            AuthHeader(
              title: l10n.allergiesTitle,
              subtitle: l10n.allergiesSubtitle,
              icon: Icons.warning_amber_rounded,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.start,
              children: allergyOptions.map((allergy) {
                final isSelected = selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(
                    _localizedOption(
                      config.allergyOptionLabels,
                      localeCode,
                      allergy,
                    ),
                    style: TextStyle(
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    final currentSelection = List<String>.from(selectedAllergies);
                    if (selected) {
                      currentSelection.add(allergy);
                    } else {
                      currentSelection.remove(allergy);
                    }
                    ref
                        .read(preferencesWizardProvider.notifier)
                        .updateAllergies(currentSelection);
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
            if (showOther) ...[
              const SizedBox(height: 32),
              _CustomAllergyInputField(
                label: l10n.allergiesOtherTitle.toUpperCase(),
                hint: l10n.allergiesOtherHint,
                controller: _customAllergyController,
                onChanged: (value) {
                  ref.read(preferencesWizardProvider.notifier).updateCustomAllergy(value);
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CustomAllergyInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CustomAllergyInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

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
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.onSurfaceVariant.withOpacity(0.5)),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
