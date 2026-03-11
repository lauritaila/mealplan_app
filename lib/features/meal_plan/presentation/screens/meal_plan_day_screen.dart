import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/swap_recipe_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/entry_actions_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/regenerate_entry_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/change_entry_date_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/save_entry_ingredients_flow.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/delete_entry_sheet.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            l10n.mealsOfDayTitle,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF64748B)),
            tooltip: l10n.mealPlanHistory,
            onPressed: () => context.push('/meal-plan/history'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
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
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3EF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _DailyMacro(label: 'PROTEIN', value: '${totals.protein?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'FAT', value: '${totals.fats?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'CARBS', value: '${totals.carbs?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'KCAL', value: '${totals.calories?.toInt() ?? 0}'),
                            ],
                          ),
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
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3EF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _DailyMacro(label: 'PROTEIN', value: '${totals.protein?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'FAT', value: '${totals.fats?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'CARBS', value: '${totals.carbs?.toInt() ?? 0}g'),
                              Container(width: 1, height: 32, color: const Color(0xFFDCDEDD)),
                              _DailyMacro(label: 'KCAL', value: '${totals.calories?.toInt() ?? 0}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ] else
                        const SizedBox(height: 24),
                    ],
                  );
                }

                final entry = entries[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.mealType != null && entry.mealType!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _formatMealType(l10n, entry.mealType),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      _MealEntryCard(
                        entry: entry,
                        hideNutritionValues: hideNutritionValues,
                        isUpdating:
                            statusUpdateState.status ==
                                DayMealEntryStatusUpdateStatus.loading ||
                            actionsState.status ==
                                MealPlanEntryActionStatus.loading,
                        onOpenRecipe: entry.recipeId > 0
                            ? () => context.push(
                                  '/recipes/${entry.recipeId}?entryId=${entry.entryId}',
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
                          selectedDate: selectedDate,
                        ),
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
                    ],
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
Future<void> _importRecipeToList(
  BuildContext context,
  WidgetRef ref, {
  required int recipeId,
}) async {
  if (recipeId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).noRecipeAssociated)),
    );
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
  required DateTime selectedDate,
}) async {
  final l10n = AppLocalizations.of(context);
  if (entry.recipeId <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.noRecipeAssociated)),
    );
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.markCompleteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.markCompleteQuestion(entry.name)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.markCompleteDeductInfo,
                    style: const TextStyle(fontSize: 12),
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
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l10n.completeAction),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final result = await ref
      .read(mealPlanEntryActionsProvider.notifier)
      .bulkDeduct(
        entry.recipeId,
        entry.servings ?? 1,
        entryId: entry.entryId,
      );
  if (!context.mounted) return;

  if (result != null) {
    ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.missing.isEmpty
              ? l10n.mealCompletedSuccess(result.deducted.length)
              : l10n.mealCompletedMissing(result.missing.length),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  } else {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.mealCompletedError)),
    );
  }
}

Future<void> _confirmDeleteEntry(
  BuildContext context,
  WidgetRef ref,
  int entryId,
  DateTime selectedDate,
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
        ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
      },
    ),
  );
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
  final pickedDate = await showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChangeEntryDateSheet(initialDate: selectedDate),
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
  ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
  ref.read(mealPlanEntryActionsProvider.notifier).reset();
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
    final l10n = AppLocalizations.of(context);
    final isSkipped = _isSkippedStatus(entry.status);
    final isCompleted = entry.status?.toLowerCase() == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFEA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.restaurant, color: Color(0xFF5C7861), size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time, Servings, KCAL sub-row
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatInt(entry.servings)} serv',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          if (!hideNutritionValues && entry.calories != null) ...[
                            const Icon(Icons.bolt, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.calories!.toInt()} Cal',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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
                    icon: const Icon(Icons.more_vert, color: Color(0xFFCBD5E1)),
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
                  color: const Color(0xFFEFF3F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniMacro(label: 'PROTEIN', value: '${entry.proteinGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: const Color(0xFFD4E0D6)),
                    _MiniMacro(label: 'FAT', value: '${entry.fatsGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: const Color(0xFFD4E0D6)),
                    _MiniMacro(label: 'CARBS', value: '${entry.carbsGrams?.toStringAsFixed(0) ?? '0'}g'),
                    Container(width: 1, height: 32, color: const Color(0xFFD4E0D6)),
                    _MiniMacro(label: 'KCAL', value: '${entry.calories?.toStringAsFixed(0) ?? '0'}'),
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
                      foregroundColor: const Color(0xFF5C7861),
                      side: const BorderSide(color: Color(0xFF5C7861)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('View recipe', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (isUpdating || isCompleted || isSkipped) ? null : onCompleteEntry,
                    style: FilledButton.styleFrom(
                      backgroundColor: isSkipped ? Colors.grey : (isCompleted ? Colors.green : const Color(0xFF5C7861)),
                      disabledBackgroundColor: isSkipped ? Colors.grey.shade300 : null,
                      disabledForegroundColor: isSkipped ? Colors.grey.shade600 : null,
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
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isUpdating) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 2, color: Color(0xFF5C7861)),
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
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8), size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
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
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5C7861) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x335C7861), blurRadius: 8, offset: Offset(0, 4))
                  ]
                : const [
                    BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2))
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayLabel(l10n, date).toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.skipMealDialogTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(l10n.skipMealDialogMessage, style: const TextStyle(color: Color(0xFF1A1E1B))),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5C7861),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.done, style: const TextStyle(fontWeight: FontWeight.w700)),
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

// removed _RegenerateDayEntrySheet class that is now handled externally
class _DailyMacro extends StatelessWidget {
  final String label;
  final String value;
  
  const _DailyMacro({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label;
  final String value;
  
  const _MiniMacro({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A9382), 
            fontSize: 11, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF263238), 
            fontSize: 18, 
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
