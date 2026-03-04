import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/swap_recipe_sheet.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanDayScreen extends ConsumerWidget {
  const MealPlanDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMealPlanDayProvider);
    final entriesAsync = ref.watch(mealPlanDayEntriesProvider(selectedDate));
    final statusUpdateState = ref.watch(dayMealEntryStatusUpdateProvider);
    final actionsState = ref.watch(mealPlanEntryActionsProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;
    final userPermissions = authState is AuthenticatedAuthState
        ? authState.user.permissions?.permissions
        : null;

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
                        onSelect: (date) => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .setDate(date),
                        onPrevious: () => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .previousDay(),
                        onNext: () => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .nextDay(),
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
                        onSelect: (date) => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .setDate(date),
                        onPrevious: () => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .previousDay(),
                        onNext: () => ref
                            .read(selectedMealPlanDayProvider.notifier)
                            .nextDay(),
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
                    isUpdating:
                        statusUpdateState.status ==
                            DayMealEntryStatusUpdateStatus.loading ||
                        actionsState.status ==
                            MealPlanEntryActionStatus.loading,
                    onOpenRecipe: entry.recipeId > 0
                        ? () => context.push('/recipes/${entry.recipeId}')
                        : null,
                    onToggleSkipped: () async {
                      final wasSkipped = _isSkippedStatus(entry.status);
                      await ref
                          .read(dayMealEntryStatusUpdateProvider.notifier)
                          .toggleSkipped(entry, selectedDate);
                      final updateState = ref.read(
                        dayMealEntryStatusUpdateProvider,
                      );

                      if (!context.mounted) return;

                      if (updateState.status ==
                              DayMealEntryStatusUpdateStatus.success &&
                          !wasSkipped) {
                        await _showSkippedMealDialog(context);
                      } else if (updateState.status ==
                          DayMealEntryStatusUpdateStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              updateState.errorMessage ?? l10n.genericError,
                            ),
                          ),
                        );
                      }
                    },
                    onDeleteEntry: () => _confirmDeleteEntry(
                      context,
                      ref,
                      entry.entryId,
                      selectedDate,
                    ),
                    onRegenerateEntry: () => _showRegenerateSheet(
                      context,
                      ref,
                      entryId: entry.entryId,
                      mealType: entry.mealType ?? '',
                      selectedDate: selectedDate,
                      userPermissions: userPermissions,
                    ),
                    onSwapRecipe: () => _swapRecipe(
                      context,
                      ref,
                      entryId: entry.entryId,
                      selectedDate: selectedDate,
                    ),
                    onChangeDate: () => _changeEntryDate(
                      context,
                      ref,
                      entryId: entry.entryId,
                      selectedDate: selectedDate,
                    ),
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

// Helper functions at widget scope
Future<void> _confirmDeleteEntry(
  BuildContext context,
  WidgetRef ref,
  int entryId,
  DateTime selectedDate,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(ctx).deleteMealDialogTitle),
      content: Text(AppLocalizations.of(ctx).deleteMealDialogMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(AppLocalizations.of(ctx).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(AppLocalizations.of(ctx).deleteAction),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await ref.read(mealPlanEntryActionsProvider.notifier).deleteEntry(entryId);

  if (!context.mounted) return;
  final state = ref.read(mealPlanEntryActionsProvider);
  if (state.status == MealPlanEntryActionStatus.success) {
    ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
  } else if (state.status == MealPlanEntryActionStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ?? AppLocalizations.of(context).genericDeleteError,
        ),
      ),
    );
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
  }
}

Future<void> _swapRecipe(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required DateTime selectedDate,
}) async {
  final selectedRecipeId = await showModalBottomSheet<int?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const SwapRecipeSheet(),
  );

  if (selectedRecipeId == null || !context.mounted) return;

  final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
  final updated = await notifier.swapRecipe(entryId, selectedRecipeId);

  if (updated == null) {
    if (!context.mounted) return;
    final state = ref.read(mealPlanEntryActionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ?? AppLocalizations.of(context).genericError,
        ),
      ),
    );
    notifier.reset();
    return;
  }

  if (!context.mounted) return;
  ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
  notifier.reset();
}

Future<void> _changeEntryDate(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required DateTime selectedDate,
}) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000, 1, 1),
    lastDate: DateTime(2100, 12, 31),
  );

  if (pickedDate == null || !context.mounted) return;
  final normalizedDate = DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
  );

  if (_isSameDate(normalizedDate, selectedDate)) return;

  final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
  await notifier.moveEntryToDate(entryId, normalizedDate);

  if (!context.mounted) return;
  final state = ref.read(mealPlanEntryActionsProvider);
  if (state.status == MealPlanEntryActionStatus.success) {
    ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
    notifier.reset();
  } else if (state.status == MealPlanEntryActionStatus.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage ?? AppLocalizations.of(context).genericMoveError,
        ),
      ),
    );
    notifier.reset();
  }
}

Future<void> _showRegenerateSheet(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required String mealType,
  required DateTime selectedDate,
  required PermissionDetails? userPermissions,
}) async {
  final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
  final updated = await showModalBottomSheet<DayMealEntry?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _RegenerateDayEntrySheet(
      entryId: entryId,
      mealType: mealType,
      userPermissions: userPermissions,
      actionsNotifier: notifier,
    ),
  );

  if (updated == null || !context.mounted) return;
  ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
  ref.read(mealPlanEntryActionsProvider.notifier).reset();
}

class _MealEntryCard extends StatelessWidget {
  final DayMealEntry entry;
  final bool hideNutritionValues;
  final bool isUpdating;
  final VoidCallback? onOpenRecipe;
  final Future<void> Function() onToggleSkipped;
  final VoidCallback onDeleteEntry;
  final VoidCallback onRegenerateEntry;
  final VoidCallback onSwapRecipe;
  final VoidCallback onChangeDate;

  const _MealEntryCard({
    required this.entry,
    required this.hideNutritionValues,
    required this.isUpdating,
    required this.onToggleSkipped,
    required this.onDeleteEntry,
    required this.onRegenerateEntry,
    required this.onSwapRecipe,
    required this.onChangeDate,
    this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSkipped = _isSkippedStatus(entry.status);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MealTypeAvatar(mealType: entry.mealType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (entry.mealType != null && entry.mealType!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatMealType(l10n, entry.mealType),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSkipped)
                  Chip(
                    label: Text(l10n.mealSkippedLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                PopupMenuButton<String>(
                  enabled: !isUpdating,
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') onDeleteEntry();
                    if (value == 'regenerate') onRegenerateEntry();
                    if (value == 'swap') onSwapRecipe();
                    if (value == 'change_date') onChangeDate();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'change_date',
                      child: ListTile(
                        leading: Icon(Icons.calendar_month_outlined),
                        title: Text(l10n.changeMealDateAction),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'swap',
                      child: ListTile(
                        leading: Icon(Icons.favorite_border),
                        title: Text(l10n.swapFavoriteAction),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'regenerate',
                      child: ListTile(
                        leading: Icon(Icons.refresh),
                        title: Text(l10n.regenerateRecipeAction),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text(
                          l10n.deleteAction,
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (bottomInset > 0)
                      PopupMenuItem(
                        enabled: false,
                        height: bottomInset,
                        padding: EdgeInsets.zero,
                        child: SizedBox(height: bottomInset),
                      ),
                  ],
                ),
              ],
            ),
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
            if (entry.categories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.categoriesTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.categories
                    .map((category) => _CategoryChip(label: category))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenRecipe,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.viewRecipeDetails),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: isUpdating ? null : onToggleSkipped,
                    icon: Icon(
                      isSkipped
                          ? Icons.replay_circle_filled
                          : Icons.do_not_disturb_on,
                    ),
                    label: Text(
                      isSkipped ? l10n.unskipMealAction : l10n.skipMealAction,
                    ),
                  ),
                ),
              ],
            ),
            if (isUpdating) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 2),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
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
    final activeEntries = entries.where(
      (entry) => !_isSkippedStatus(entry.status),
    );
    return _TotalsSummary(
      protein: _sumNullable(activeEntries.map((entry) => entry.proteinGrams)),
      fats: _sumNullable(activeEntries.map((entry) => entry.fatsGrams)),
      carbs: _sumNullable(activeEntries.map((entry) => entry.carbsGrams)),
      calories: _sumNullable(activeEntries.map((entry) => entry.calories)),
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

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isSkippedStatus(String? status) {
  if (status == null) return false;
  final value = status.trim().toLowerCase();
  return value == 'skipped' || value == 'skiped';
}

Future<void> _showSkippedMealDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.skipMealDialogTitle),
        content: Text(l10n.skipMealDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.done),
          ),
        ],
      );
    },
  );
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

// ---------------------------------------------------------------------------
// _RegenerateDayEntrySheet
// ---------------------------------------------------------------------------
class _RegenerateDayEntrySheet extends StatefulWidget {
  final int entryId;
  final String mealType;
  final PermissionDetails? userPermissions;
  final MealPlanEntryActions actionsNotifier;

  const _RegenerateDayEntrySheet({
    required this.entryId,
    required this.mealType,
    required this.userPermissions,
    required this.actionsNotifier,
  });

  @override
  State<_RegenerateDayEntrySheet> createState() =>
      _RegenerateDayEntrySheetState();
}

class _RegenerateDayEntrySheetState extends State<_RegenerateDayEntrySheet> {
  final _descController = TextEditingController();
  int? _selectedMaxTime;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final times = widget.userPermissions?.mealPlanTime;
    if (times != null && times.isNotEmpty) {
      _selectedMaxTime = times.last;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final times = widget.userPermissions?.mealPlanTime ?? const [];
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.regenerateRecipeAction,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.regenerateSheetSubtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.regenerateSheetNotesLabel,
                hintText: l10n.regenerateSheetNotesHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (times.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.regenerateSheetMaxPrepTimeLabel,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: times.map((t) {
                  final isSelected = _selectedMaxTime == t;
                  return ChoiceChip(
                    label: Text(l10n.minutesShortWithPlaceholder('$t')),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedMaxTime = t),
                  );
                }).toList(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.regenerateSheetButton),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = ChangeMealPlanRecipeRequest(
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      mealTypes: [widget.mealType],
      maxTotalTimeMinutes: _selectedMaxTime,
    );

    final updated = await widget.actionsNotifier.changeRecipe(
      widget.entryId,
      request,
    );

    if (!mounted) return;
    if (updated != null) {
      Navigator.of(context).pop(updated);
    } else {
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.of(context).genericRegenerateError;
      });
    }
  }
}
