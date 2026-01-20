import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

class MealPlanDayScreen extends ConsumerWidget {
  const MealPlanDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMealPlanDayProvider);
    final entriesAsync = ref.watch(mealPlanDayEntriesProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals of the day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(mealPlanDayEntriesProvider(selectedDate)),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error is AppError
              ? error.message
              : 'Could not load the day. Please try again.',
          onRetry: () =>
              ref.invalidate(mealPlanDayEntriesProvider(selectedDate)),
        ),
        data: (entries) {
          final totals = _TotalsSummary.fromEntries(entries);

          if (entries.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      _DaySelector(
                        selectedDate: selectedDate,
                        onSelect: (date) =>
                            ref
                                    .read(selectedMealPlanDayProvider.notifier)
                                    .state =
                                date,
                        onPrevious: () =>
                            ref
                                .read(selectedMealPlanDayProvider.notifier)
                                .state = selectedDate.subtract(
                              const Duration(days: 1),
                            ),
                        onNext: () =>
                            ref
                                .read(selectedMealPlanDayProvider.notifier)
                                .state = selectedDate.add(
                              const Duration(days: 1),
                            ),
                      ),
                      const SizedBox(height: 12),
                      _TotalsSummaryCard(summary: totals),
                    ],
                  ),
                ),
                const Expanded(child: _EmptyState()),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
              await ref.read(mealPlanDayEntriesProvider(selectedDate).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      _DaySelector(
                        selectedDate: selectedDate,
                        onSelect: (date) =>
                            ref
                                    .read(selectedMealPlanDayProvider.notifier)
                                    .state =
                                date,
                        onPrevious: () =>
                            ref
                                .read(selectedMealPlanDayProvider.notifier)
                                .state = selectedDate.subtract(
                              const Duration(days: 1),
                            ),
                        onNext: () =>
                            ref
                                .read(selectedMealPlanDayProvider.notifier)
                                .state = selectedDate.add(
                              const Duration(days: 1),
                            ),
                      ),
                      const SizedBox(height: 12),
                      _TotalsSummaryCard(summary: totals),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final entry = entries[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealEntryCard(entry: entry),
                );
              },
              itemCount: entries.length + 1,
            ),
          );
        },
      ),
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  final DayMealEntry entry;

  const _MealEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: _MealTypeAvatar(mealType: entry.mealType),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          entry.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.mealType != null && entry.mealType!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatMealType(entry.mealType),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            // const SizedBox(height: 6),
            // Text(
            //   entry.description,
            //   maxLines: 2,
            //   overflow: TextOverflow.ellipsis,
            //   style: Theme.of(context).textTheme.bodySmall,
            // ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(label: 'Cal', value: _formatDouble(entry.calories)),
                _MetricChip(
                  label: 'Servings',
                  value: _formatInt(entry.servings),
                ),
                _MetricChip(
                  label: 'Fat',
                  value: _formatDouble(
                    entry.fatsGrams,
                    decimals: 1,
                    suffix: 'g',
                  ),
                ),
                _MetricChip(
                  label: 'Carbs',
                  value: _formatDouble(
                    entry.carbsGrams,
                    decimals: 1,
                    suffix: 'g',
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                entry.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                entry.instructions.isEmpty
                    ? 'No instructions.'
                    : entry.instructions,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              if (entry.ingredients.isEmpty)
                Text(
                  'No ingredients.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...entry.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${_formatIngredient(ingredient)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _TotalsSummary {
  final double? protein;
  final double? fats;
  final double? carbs;
  final double? calories;

  const _TotalsSummary({
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.calories,
  });

  factory _TotalsSummary.fromEntries(List<DayMealEntry> entries) {
    return _TotalsSummary(
      protein: _sumNullable(entries.map((entry) => entry.proteinGrams)),
      fats: _sumNullable(entries.map((entry) => entry.fatsGrams)),
      carbs: _sumNullable(entries.map((entry) => entry.carbsGrams)),
      calories: _sumNullable(entries.map((entry) => entry.calories)),
    );
  }
}

class _TotalsSummaryCard extends StatelessWidget {
  final _TotalsSummary summary;

  const _TotalsSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TotalMetric(
              label: 'Proteína',
              value: _formatDouble(summary.protein, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _TotalMetric(
              label: 'Fat',
              value: _formatDouble(summary.fats, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _TotalMetric(
              label: 'Carbs',
              value: _formatDouble(summary.carbs, suffix: 'g'),
            ),
          ),
          Expanded(
            child: _TotalMetric(
              label: 'Kcal',
              value: _formatDouble(summary.calories),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TotalMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _DaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DaySelector({
    required this.selectedDate,
    required this.onSelect,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      5,
      (index) => selectedDate.add(Duration(days: index - 2)),
    );
    return Row(
      children: [
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days
                .map(
                  (date) => Expanded(
                    child: _DayChip(
                      date: date,
                      isSelected: _isSameDate(date, selectedDate),
                      onTap: () => onSelect(date),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayLabel(date),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date.day.toString(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealTypeAvatar extends StatelessWidget {
  final String? mealType;

  const _MealTypeAvatar({required this.mealType});

  @override
  Widget build(BuildContext context) {
    final icon = _mealTypeIcon(mealType);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: colorScheme.onPrimaryContainer),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No meals logged for today.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

String _formatDouble(double? value, {int decimals = 0, String suffix = ''}) {
  if (value == null) return '--';
  final formatted = value.toStringAsFixed(decimals);
  return suffix.isEmpty ? formatted : '$formatted$suffix';
}

String _formatInt(int? value) {
  if (value == null) return '--';
  return value.toString();
}

String _formatIngredient(DayMealIngredient ingredient) {
  final quantity = ingredient.quantity;
  final unit = ingredient.unit ?? '';
  final quantityText = quantity == null ? '' : quantity.toString();
  final unitText = unit.isEmpty ? '' : ' $unit';
  final prefix = (quantityText + unitText).trim();
  if (prefix.isEmpty) return ingredient.name;
  return '$prefix ${ingredient.name}'.trim();
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _weekdayLabel(DateTime date) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[date.weekday - 1];
}

double? _sumNullable(Iterable<double?> values) {
  var total = 0.0;
  var hasValue = false;
  for (final value in values) {
    if (value != null) {
      total += value;
      hasValue = true;
    }
  }
  return hasValue ? total : null;
}

IconData _mealTypeIcon(String? mealType) {
  final value = (mealType ?? '').toLowerCase();
  switch (value) {
    case 'breakfast':
    case 'desayuno':
      return Icons.wb_sunny_outlined;
    case 'lunch':
    case 'almuerzo':
      return Icons.lunch_dining;
    case 'dinner':
    case 'cena':
      return Icons.dinner_dining;
    case 'snack':
    case 'merienda':
      return Icons.fastfood;
    default:
      return Icons.restaurant;
  }
}

String _formatMealType(String? mealType) {
  if (mealType == null || mealType.trim().isEmpty) return '';
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return 'Breakfast';
    case 'lunch':
      return 'Lunch';
    case 'dinner':
      return 'Dinner';
    case 'snack':
      return 'Snack';
    default:
      return mealType;
  }
}
