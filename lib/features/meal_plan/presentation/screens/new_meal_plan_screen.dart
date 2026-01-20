import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

class NewMealPlanScreen extends ConsumerStatefulWidget {
  const NewMealPlanScreen({super.key});

  @override
  ConsumerState<NewMealPlanScreen> createState() => _NewMealPlanScreenState();
}

class _NewMealPlanScreenState extends ConsumerState<NewMealPlanScreen> {
  final _descriptionController = TextEditingController();
  final Set<String> _selectedMealTypes = {'breakfast', 'lunch', 'dinner'};
  int _selectedDays = 5;
  int _peopleCount = 2;

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
      _peopleCount = 2;
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
    });
    ref.read(mealPlanGeneratorProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('New Plan'),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
                  const SizedBox(height: 4),
                  const Text(
                    'Configure your plan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Define duration, people and base meals.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Duration',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: availableDurations
                          .map(
                            (days) => _PillOption(
                              label: '$days days',
                              selected: _selectedDays == days,
                              onTap: () => setState(() => _selectedDays = days),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _Section(
                    title: 'Diners',
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
                              '$_peopleCount people',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                  if (showMealTypeSelection)
                    _Section(
                      title: 'Meal types',
                      child: Column(
                        children: [
                          if (availableMealTypes.contains('breakfast'))
                            _MealTypeTile(
                              title: 'Breakfast',
                              subtitle: 'Energy for the day',
                              selected: _selectedMealTypes.contains(
                                'breakfast',
                              ),
                              onTap: () => _toggleMealType('breakfast'),
                            ),
                          if (availableMealTypes.contains('breakfast') &&
                              availableMealTypes.contains('lunch'))
                            const SizedBox(height: 10),
                          if (availableMealTypes.contains('lunch'))
                            _MealTypeTile(
                              title: 'Lunch',
                              subtitle: 'Main meal',
                              selected: _selectedMealTypes.contains('lunch'),
                              onTap: () => _toggleMealType('lunch'),
                            ),
                          if (availableMealTypes.contains('lunch') &&
                              availableMealTypes.contains('snack'))
                            const SizedBox(height: 10),
                          if (availableMealTypes.contains('snack'))
                            _MealTypeTile(
                              title: 'Snack',
                              subtitle: 'Something light',
                              selected: _selectedMealTypes.contains('snack'),
                              onTap: () => _toggleMealType('snack'),
                            ),
                          if (availableMealTypes.contains('snack') &&
                              availableMealTypes.contains('dinner'))
                            const SizedBox(height: 10),
                          if (availableMealTypes.contains('dinner'))
                            _MealTypeTile(
                              title: 'Dinner',
                              subtitle: 'Light and nutritious',
                              selected: _selectedMealTypes.contains('dinner'),
                              onTap: () => _toggleMealType('dinner'),
                            ),
                        ],
                      ),
                    ),
                  _Section(
                    title: 'Notes (optional)',
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E.g.: Lactose-free, more proteins...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onGenerate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
                          : const Text('Continue'),
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
    context.push(
      '/meal-plan/loading',
      extra: {
        'description': _descriptionController.text.trim(),
        'numberOfDays': _selectedDays,
        'quantityOfPeople': _peopleCount,
        'mealTypes': _selectedMealTypes.toList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          border: Border.all(
            color: selected ? colorScheme.primary : theme.dividerColor,
            width: 1.3,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? colorScheme.primary
                : theme.textTheme.bodyLarge?.color ?? Colors.black87,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor, width: 1.2),
          color: theme.colorScheme.surface,
        ),
        child: Icon(icon, size: 20, color: theme.iconTheme.color),
      ),
    );
  }
}

class _MealTypeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MealTypeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colorScheme.primary : theme.dividerColor,
            width: 1.2,
          ),
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.08)
              : theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? colorScheme.primary : theme.disabledColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
