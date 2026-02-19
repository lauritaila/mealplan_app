import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanDayScreen extends ConsumerWidget {
  const MealPlanDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMealPlanDayProvider);
    final entriesAsync = ref.watch(mealPlanDayEntriesProvider(selectedDate));
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mealsOfDayTitle),
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
          message: localizeErrorCode(
            l10n,
            error is AppError ? error.code : null,
            fallback: error is AppError ? error.message : null,
          ),
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
                      if (!hideNutritionValues) ...[
                        const SizedBox(height: 12),
                        NutritionSummaryCard(
                          protein: totals.protein,
                          fats: totals.fats,
                          carbs: totals.carbs,
                          calories: totals.calories,
                        ),
                      ],
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
                      if (!hideNutritionValues) ...[
                        const SizedBox(height: 12),
                        NutritionSummaryCard(
                          protein: totals.protein,
                          fats: totals.fats,
                          carbs: totals.carbs,
                          calories: totals.calories,
                        ),
                        const SizedBox(height: 16),
                      ] else
                        const SizedBox(height: 8),
                    ],
                  );
                }

                final entry = entries[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealEntryCard(
                    entry: entry,
                    hideNutritionValues: hideNutritionValues,
                  ),
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
  final bool hideNutritionValues;

  const _MealEntryCard({
    required this.entry,
    required this.hideNutritionValues,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  _formatMealType(l10n, entry.mealType),
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
                _MetricChip(
                  label: l10n.metricServings,
                  value: _formatInt(entry.servings),
                ),
                if (!hideNutritionValues)
                  _MetricChip(
                    label: l10n.metricCalories,
                    value: _formatDouble(entry.calories),
                  ),
                if (!hideNutritionValues)
                  _MetricChip(
                    label: l10n.metricFat,
                    value: _formatDouble(
                      entry.fatsGrams,
                      decimals: 1,
                      suffix: 'g',
                    ),
                  ),
                if (!hideNutritionValues)
                  _MetricChip(
                    label: l10n.metricCarbs,
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
                l10n.descriptionTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                entry.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.instructionsTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                entry.instructions.isEmpty
                    ? l10n.noInstructions
                    : entry.instructions,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.ingredientsTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              if (entry.ingredients.isEmpty)
                Text(
                  l10n.noIngredients,
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
    final l10n = AppLocalizations.of(context);
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
                _weekdayLabel(l10n, date),
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
    final l10n = AppLocalizations.of(context);
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
              label: Text(l10n.retry),
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.noMealsLoggedToday,
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

String _weekdayLabel(AppLocalizations l10n, DateTime date) {
  const labels = [
    'weekdayMonShort',
    'weekdayTueShort',
    'weekdayWedShort',
    'weekdayThuShort',
    'weekdayFriShort',
    'weekdaySatShort',
    'weekdaySunShort',
  ];
  final key = labels[date.weekday - 1];
  switch (key) {
    case 'weekdayMonShort':
      return l10n.weekdayMonShort;
    case 'weekdayTueShort':
      return l10n.weekdayTueShort;
    case 'weekdayWedShort':
      return l10n.weekdayWedShort;
    case 'weekdayThuShort':
      return l10n.weekdayThuShort;
    case 'weekdayFriShort':
      return l10n.weekdayFriShort;
    case 'weekdaySatShort':
      return l10n.weekdaySatShort;
    case 'weekdaySunShort':
      return l10n.weekdaySunShort;
    default:
      return '';
  }
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

String _formatMealType(AppLocalizations l10n, String? mealType) {
  if (mealType == null || mealType.trim().isEmpty) return '';
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return l10n.mealTypeBreakfast;
    case 'lunch':
      return l10n.mealTypeLunch;
    case 'dinner':
      return l10n.mealTypeDinner;
    case 'snack':
      return l10n.mealTypeSnack;
    default:
      return mealType;
  }
}
