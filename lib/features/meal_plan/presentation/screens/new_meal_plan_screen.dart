import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/preferences_details_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newPlanTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF002140))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF002140)),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: Text(
              l10n.clear,
              style: const TextStyle(color: Color(0xFF4C6B4F), fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF002140),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.configurePlanSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey.shade400,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF002140),
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
                      style: const TextStyle(fontSize: 15, color: Color(0xFF002140)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintText: l10n.notesHint,
                        hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Section(
                    title: '',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.usePantryLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF002140)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.usePantrySubtitle,
                                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
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
                            activeTrackColor: const Color(0xFF4C6B4F),
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
                        backgroundColor: const Color(0xFF4C6B4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.continueLabel),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey.shade300,
              letterSpacing: 0.5,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F0E8) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF4C6B4F) : const Color(0xFFE8EEF2),
            width: selected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: const Color(0xFF002140),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF002140)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4C6B4F) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF4C6B4F) : const Color(0xFFE8EEF2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
            color: selected ? Colors.white : const Color(0xFF002140),
          ),
        ),
      ),
    );
  }
}
