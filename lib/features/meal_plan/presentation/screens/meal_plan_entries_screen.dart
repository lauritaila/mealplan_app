import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';

import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/change_entry_date_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/delete_entry_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/entry_actions_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/regenerate_entry_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/save_entry_ingredients_flow.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/swap_recipe_sheet.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class MealPlanEntriesScreen extends ConsumerWidget {
  final int planId;
  final String? planName;

  const MealPlanEntriesScreen({super.key, required this.planId, this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesProvider(planId));
    final actionsState = ref.watch(mealPlanEntryActionsProvider);
    final statusUpdateState = ref.watch(dayMealEntryStatusUpdateProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    final hideNutritionValues = authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;
    final userPermissions = authState is AuthenticatedAuthState
        ? authState.user.permissions?.permissions
        : null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          planName ?? l10n.planEntriesTitle,
          style: textTheme.titleLarge?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                localizeErrorCode(l10n, error is AppError ? error.code : null),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(mealPlanEntriesProvider(planId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(child: Text(l10n.noEntriesInPlan));
          }

          // Group entries by date
          final grouped = <DateTime, List<DayMealEntry>>{};
          for (final e in entries) {
            final date = e.mealDate != null
                ? DateTime(e.mealDate!.year, e.mealDate!.month, e.mealDate!.day)
                : DateTime(2000);
            grouped.putIfAbsent(date, () => []).add(e);
          }
          final sortedDates = grouped.keys.toList()..sort();

          // Calculate date range for the header
          String dateRangeHeader = '';
          if (sortedDates.isNotEmpty) {
            final firstDate = sortedDates.first;
            final lastDate = sortedDates.last;
            final locale = Localizations.localeOf(context).toString();
            if (firstDate.year != 2000) {
              if (firstDate.month == lastDate.month && firstDate.year == lastDate.year) {
                final monthName = DateFormat('MMMM', locale).format(firstDate);
                dateRangeHeader = '${firstDate.day} - ${lastDate.day} de ${monthName[0].toUpperCase()}${monthName.substring(1)}';
              } else {
                final start = DateFormat('d MMM', locale).format(firstDate);
                final end = DateFormat('d MMM', locale).format(lastDate);
                dateRangeHeader = '$start - $end';
              }
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            itemCount: sortedDates.length + 1, // +1 for the top header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Return top header
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateRangeHeader.isNotEmpty ? dateRangeHeader : (planName ?? l10n.planEntriesTitle),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: customColors.textDarkBlue,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.configurePlanSubtitle, // Using a generic localized description for now
                        style: textTheme.bodyMedium?.copyWith(
                          color: customColors.slateGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final di = index - 1;
              final date = sortedDates[di];
              final dayEntries = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateHeader(date: date),
                  const SizedBox(height: 16),
                  ...dayEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _MealEntryCard(
                        entry: entry,
                        hideNutritionValues: hideNutritionValues,
                        isUpdating:
                            statusUpdateState.status ==
                                DayMealEntryStatusUpdateStatus.loading ||
                            actionsState.status ==
                                MealPlanEntryActionStatus.loading,
                        onOpenRecipe: entry.recipeId > 0
                            ? () => context.push(
                                  '/recipes/${entry.recipeId}?entryId=${entry.entryId}&status=${entry.status}',
                                )
                            : null,
                        onImportRecipeToList: () => _importRecipeToList(
                          context,
                          ref,
                          recipeId: entry.recipeId,
                        ),
                        onCompleteEntry: () => _confirmComplete(
                          context,
                          ref,
                          entry: entry,
                          planId: planId,
                        ),
                        onToggleSkipped: () async {
                          final wasSkipped = _isSkippedStatus(entry.status);
                          await ref
                              .read(dayMealEntryStatusUpdateProvider.notifier)
                              .toggleSkipped(entry, date);
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
                            CustomSnackbar.showInfo(context, 
                                  updateState.errorMessage ?? l10n.genericError,
                                );
                          }
                          // invalidate entries screen provider after completion correctly
                          ref.invalidate(mealPlanEntriesProvider(planId));
                        },
                        onDeleteEntry: () => _confirmDeleteEntry(
                          context,
                          ref,
                          entry.entryId,
                          planId,
                        ),
                        onRegenerateEntry: () => _showRegenerateSheet(
                          context,
                          ref,
                          entryId: entry.entryId,
                          mealType: entry.mealType ?? '',
                          planId: planId,
                          userPermissions: userPermissions,
                        ),
                        onSwapRecipe: () => _swapRecipe(
                          context,
                          ref,
                          entryId: entry.entryId,
                          planId: planId,
                        ),
                        onChangeDate: () => _changeEntryDate(
                          context,
                          ref,
                          entryId: entry.entryId,
                          planId: planId,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    if (date.year == 2000) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final df = DateFormat('EEEE, d MMMM', Localizations.localeOf(context).toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            df.format(date).toUpperCase(),
            style: textTheme.labelLarge?.copyWith(
              color: customColors.darkSage,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  final DayMealEntry entry;
  final bool hideNutritionValues;
  final bool isUpdating;
  final VoidCallback? onOpenRecipe;
  final VoidCallback onImportRecipeToList;
  final VoidCallback onCompleteEntry;
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
    required this.onImportRecipeToList,
    required this.onCompleteEntry,
    required this.onDeleteEntry,
    required this.onRegenerateEntry,
    required this.onSwapRecipe,
    required this.onChangeDate,
    this.onOpenRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final isSkipped = _isSkippedStatus(entry.status);
    final isCompleted = entry.status?.toLowerCase() == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: customColors.chartTabBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(Icons.restaurant, color: customColors.darkSage, size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: customColors.textDarkBlue,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time, Servings, KCAL sub-row
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: customColors.slateGrey),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatInt(entry.servings)} ${l10n.servingShort}',
                            style: textTheme.bodySmall?.copyWith(
                              color: customColors.slateGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!hideNutritionValues && entry.calories != null) ...[
                            Icon(Icons.bolt, size: 14, color: customColors.slateGrey),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.calories!.toInt()} ${l10n.metricCalories}',
                              style: textTheme.bodySmall?.copyWith(
                                color: customColors.slateGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_vert, color: customColors.slateGrey?.withValues(alpha: 0.4)),
                    onPressed: isUpdating
                        ? null
                        : () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => EntryActionsSheet(
                                entry: entry,
                                onToggleSkipped: onToggleSkipped,
                                onImportRecipeToList: onImportRecipeToList,
                                onDeleteEntry: onDeleteEntry,
                                onRegenerateEntry: onRegenerateEntry,
                                onSwapRecipe: onSwapRecipe,
                                onChangeDate: onChangeDate,
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
            if (!hideNutritionValues) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: customColors.chartTabBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniMacro(label: l10n.metricProtein.toUpperCase(), value: '${entry.proteinGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: customColors.darkSage?.withValues(alpha: 0.1)),
                    _MiniMacro(label: l10n.metricFat.toUpperCase(), value: '${entry.fatsGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: customColors.darkSage?.withValues(alpha: 0.1)),
                    _MiniMacro(label: l10n.metricCarbs.toUpperCase(), value: '${entry.carbsGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: customColors.darkSage?.withValues(alpha: 0.1)),
                    _MiniMacro(label: l10n.metricCalories.toUpperCase(), value: entry.calories?.toStringAsFixed(0) ?? '0'),
                  ],
                ),
              ),
            ],
            if (entry.categories.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.categories
                    .map((category) => _CategoryChip(label: category))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenRecipe,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: customColors.darkSage,
                      side: BorderSide(color: customColors.darkSage!.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      l10n.viewRecipeDetails,
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (isUpdating || isCompleted || isSkipped) ? null : onCompleteEntry,
                    style: FilledButton.styleFrom(
                      backgroundColor: isSkipped ? customColors.slateGrey : (isCompleted ? Colors.green : customColors.darkSage),
                      disabledBackgroundColor: isSkipped ? customColors.slateGrey?.withValues(alpha: 0.2) : null,
                      disabledForegroundColor: isSkipped ? customColors.slateGrey?.withValues(alpha: 0.6) : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(0, 52), // Uniform height
                    ),
                    icon: Icon(
                        isSkipped ? Icons.do_not_disturb_on 
                        : (isCompleted ? Icons.check_circle : Icons.check_circle_outline), 
                        size: 20
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isSkipped ? l10n.mealSkippedLabel : (isCompleted ? l10n.mealCompletedLabel : l10n.completeAction),
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: isSkipped ? customColors.slateGrey : (isCompleted ? customColors.darkSage : Colors.white)),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isUpdating) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(minHeight: 2, color: customColors.darkSage),
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
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: customColors.darkSage,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final String value;
  
  const _MiniMacro({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: customColors.darkSage?.withValues(alpha: 0.7),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

Future<void> _importRecipeToList(
  BuildContext context,
  WidgetRef ref, {
  required int recipeId,
}) async {
  if (recipeId <= 0) {
    CustomSnackbar.showInfo(context, AppLocalizations.of(context).noRecipeAssociated);
    return;
  }
  await SaveEntryIngredientsFlow.show(
    context: context,
    ref: ref,
    recipeId: recipeId,
  );
}

Future<void> _confirmComplete(
  BuildContext context,
  WidgetRef ref, {
  required DayMealEntry entry,
  required int planId,
}) async {
  final l10n = AppLocalizations.of(context);
  if (entry.recipeId <= 0) {
    CustomSnackbar.showInfo(context, l10n.noRecipeAssociated);
    return;
  }
  final customColors = Theme.of(context).extension<AppCustomColors>()!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        l10n.markCompleteDialogTitle,
        style: TextStyle(fontWeight: FontWeight.w900, color: customColors.textDarkBlue),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.markCompleteQuestion(entry.name),
            style: TextStyle(color: customColors.slateGrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.markCompleteDeductInfo,
                    style: TextStyle(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            l10n.cancel.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w800, color: customColors.slateGrey),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: customColors.darkSage,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            l10n.completeAction.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final result = await ref
      .read(mealPlanEntryActionsProvider.notifier)
      .bulkDeduct(
        entry.recipeId,
        entry.servings ?? 1,
        entryId: entry.entryId,
      );
  if (!context.mounted) return;

  if (result != null) {
    ref.invalidate(mealPlanEntriesProvider(planId));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
    CustomSnackbar.showSuccess(
      context,
      result.missing.isEmpty
          ? l10n.mealCompletedSuccess(result.deducted.length)
          : l10n.mealCompletedMissing(result.missing.length),
    );
  } else {
    CustomSnackbar.showError(context, l10n.mealCompletedError);
  }
}

Future<void> _confirmDeleteEntry(
  BuildContext context,
  WidgetRef ref,
  int entryId,
  int planId,
) async {
  final actionsNotifier = ref.read(mealPlanEntryActionsProvider.notifier);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DeleteEntrySheet(
      entryId: entryId,
      actionsNotifier: actionsNotifier,
      onDeleted: () {
        ref.invalidate(mealPlanEntriesProvider(planId));
      },
    ),
  );
}

Future<void> _swapRecipe(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required int planId,
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
    CustomSnackbar.showInfo(context, 
          state.errorMessage ?? AppLocalizations.of(context).genericError,
        );
    notifier.reset();
    return;
  }

  if (!context.mounted) return;
  ref.invalidate(mealPlanEntriesProvider(planId));
  notifier.reset();
}

Future<void> _changeEntryDate(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required int planId,
}) async {
  final pickedDate = await showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChangeEntryDateSheet(initialDate: DateTime.now()),
  );

  if (pickedDate == null || !context.mounted) return;
  
  // Normalized date for storing
  final normalizedDate = DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
  );

  final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
  await notifier.moveEntryToDate(entryId, normalizedDate);

  if (!context.mounted) return;
  final state = ref.read(mealPlanEntryActionsProvider);
  if (state.status == MealPlanEntryActionStatus.success) {
    ref.invalidate(mealPlanEntriesProvider(planId));
    notifier.reset();
  } else if (state.status == MealPlanEntryActionStatus.error) {
    CustomSnackbar.showInfo(context, 
          state.errorMessage ?? AppLocalizations.of(context).genericMoveError,
        );
    notifier.reset();
  }
}

Future<void> _showRegenerateSheet(
  BuildContext context,
  WidgetRef ref, {
  required int entryId,
  required String mealType,
  required int planId,
  required PermissionDetails? userPermissions,
}) async {
  final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
  final updated = await showModalBottomSheet<DayMealEntry?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => RegenerateEntrySheet(
      entryId: entryId,
      mealType: mealType,
      userPermissions: userPermissions,
      actionsNotifier: notifier,
    ),
  );

  if (updated == null || !context.mounted) return;
  ref.invalidate(mealPlanEntriesProvider(planId));
  ref.read(mealPlanEntryActionsProvider.notifier).reset();
}

Future<void> _showSkippedMealDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.skipMealDialogTitle),
      content: Text(l10n.skipMealDialogMessage),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.done),
        ),
      ],
    ),
  );
}

bool _isSkippedStatus(String? status) {
  if (status == null) return false;
  return status.toLowerCase() == 'skipped';
}

String _formatInt(int? value) {
  if (value == null) return '--';
  return value.toString();
}


