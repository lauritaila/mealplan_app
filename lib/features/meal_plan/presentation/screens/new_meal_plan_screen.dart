import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/preferences_details_provider.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class NewMealPlanScreen extends ConsumerStatefulWidget {
  const NewMealPlanScreen({super.key});

  @override
  ConsumerState<NewMealPlanScreen> createState() => _NewMealPlanScreenState();
}

class _NewMealPlanScreenState extends ConsumerState<NewMealPlanScreen> {
  final _descriptionController = TextEditingController();
  final Set<String> _selectedMealTypes = {
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  };
  int _selectedDays = 5;
  int _peopleCount = 2;
  bool _usePantry = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final preferences = ref.read(preferencesDetailsProvider);
      final prefCount = preferences.householdSize;
      setState(() {
        _peopleCount = prefCount > 0 ? prefCount : 2;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    final availableDurations = ref.read(availableDurationsProvider);
    final availableMealTypes = ref.read(availableMealTypesProvider);
    final showMealTypeSelection = ref.read(shouldShowMealTypeSelectionProvider);

    setState(() {
      _selectedDays = availableDurations.contains(5)
          ? 5
          : availableDurations.first;
      final preferences = ref.read(preferencesDetailsProvider);
      final prefCount = preferences.householdSize;
      _peopleCount = prefCount > 0 ? prefCount : 2;
      if (showMealTypeSelection) {
        _selectedMealTypes
          ..clear()
          ..addAll(availableMealTypes);
      } else {
        _selectedMealTypes
          ..clear()
          ..add(availableMealTypes.first);
      }
      _descriptionController.clear();
      _usePantry = true;
    });
    ref.read(mealPlanGeneratorProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mealPlanGeneratorProvider);
    final isLoading = state.status == MealPlanGeneratorStatus.loading;

    final availableDurations = ref.watch(availableDurationsProvider);
    final availableMealTypes = ref.watch(availableMealTypesProvider);
    final showMealTypeSelection = ref.watch(
      shouldShowMealTypeSelectionProvider,
    );

    // Ensure selected values are valid
    if (!availableDurations.contains(_selectedDays)) {
      _selectedDays = availableDurations.first;
    }
    if (showMealTypeSelection) {
      _selectedMealTypes.retainWhere(
        (type) => availableMealTypes.contains(type),
      );
      if (_selectedMealTypes.isEmpty) {
        _selectedMealTypes.addAll(availableMealTypes);
      }
    } else {
      _selectedMealTypes.clear();
      _selectedMealTypes.add(availableMealTypes.first);
    }

    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.newPlanTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: customColors.textDarkBlue),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: Text(
              l10n.clear.toUpperCase(),
              style: textTheme.labelLarge?.copyWith(
                color: customColors.darkSage,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    l10n.configurePlanTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: customColors.textDarkBlue,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.configurePlanSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: customColors.slateGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: l10n.durationTitle,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableDurations
                          .map(
                            (days) => _PillOption(
                              label: l10n.daysLabel(days),
                              selected: _selectedDays == days,
                              onTap: () => setState(() => _selectedDays = days),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _Section(
                    title: l10n.dinersTitle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: customColors.chartTabBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _IconCircleButton(
                            icon: Icons.remove,
                            onTap: () => setState(
                              () => _peopleCount = (_peopleCount > 1)
                                  ? _peopleCount - 1
                                  : 1,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                l10n.peopleCount(_peopleCount),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: customColors.textDarkBlue,
                                ),
                              ),
                            ),
                          ),
                          _IconCircleButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _peopleCount += 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showMealTypeSelection)
                    _Section(
                      title: l10n.mealTypesTitle,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (availableMealTypes.contains('breakfast'))
                            _MealTypePill(
                              label: l10n.mealTypeBreakfast,
                              selected: _selectedMealTypes.contains('breakfast'),
                              onTap: () => _toggleMealType('breakfast'),
                            ),
                          if (availableMealTypes.contains('lunch'))
                            _MealTypePill(
                              label: l10n.mealTypeLunch,
                              selected: _selectedMealTypes.contains('lunch'),
                              onTap: () => _toggleMealType('lunch'),
                            ),
                          if (availableMealTypes.contains('dinner'))
                            _MealTypePill(
                              label: l10n.mealTypeDinner,
                              selected: _selectedMealTypes.contains('dinner'),
                              onTap: () => _toggleMealType('dinner'),
                            ),
                          if (availableMealTypes.contains('snack'))
                            _MealTypePill(
                              label: l10n.mealTypeSnack,
                              selected: _selectedMealTypes.contains('snack'),
                              onTap: () => _toggleMealType('snack'),
                            ),
                        ],
                      ),
                    ),
                  _Section(
                    title: l10n.notesOptionalTitle,
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: textTheme.bodyLarge?.copyWith(color: customColors.textDarkBlue),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: customColors.chartTabBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        hintText: l10n.notesHint,
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: customColors.slateGrey?.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Section(
                    title: '',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: customColors.chartTabBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.usePantryLabel,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: customColors.textDarkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.usePantrySubtitle,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: customColors.slateGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _usePantry,
                            onChanged: (val) {
                              setState(() {
                                _usePantry = val;
                              });
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: customColors.darkSage,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.darkSage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        textStyle: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.continueLabel.toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMealType(String type) {
    final availableMealTypes = ref.read(availableMealTypesProvider);
    if (!availableMealTypes.contains(type)) return;
    setState(() {
      if (_selectedMealTypes.contains(type)) {
        _selectedMealTypes.remove(type);
      } else {
        _selectedMealTypes.add(type);
      }
    });
  }

  void _onGenerate() {
    final peopleCount = _peopleCount;
    context.push(
      '/meal-plan/loading',
      extra: {
        'description': _descriptionController.text.trim(),
        'numberOfDays': _selectedDays,
        'quantityOfPeople': peopleCount,
        'mealTypes': _selectedMealTypes.toList(),
        'usePantry': _usePantry,
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: child);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: customColors.darkSage,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? customColors.chartTabBackground : Colors.white,
          border: Border.all(
            color: selected ? customColors.darkSage! : Colors.grey.shade200,
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? customColors.darkSage : customColors.textDarkBlue,
          ),
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Icon(icon, size: 24, color: customColors.textDarkBlue),
      ),
    );
  }
}

class _MealTypePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MealTypePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? customColors.darkSage : Colors.white,
          border: Border.all(
            color: selected ? customColors.darkSage! : Colors.grey.shade200,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : customColors.textDarkBlue,
          ),
        ),
      ),
    );
  }
}
