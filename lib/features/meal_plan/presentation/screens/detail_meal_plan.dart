import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/swap_recipe_sheet.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

// Extracted Widgets
import '../widgets/detail_meal_plan/drag_drop_hint.dart';
import '../widgets/detail_meal_plan/day_section.dart';
import '../widgets/detail_meal_plan/date_selection_sheet.dart';
import '../widgets/detail_meal_plan/regenerate_entry_sheet.dart';
import '../widgets/detail_meal_plan/delete_plan_sheet.dart';
import '../widgets/detail_meal_plan/save_ingredients_flow.dart';

class DetailMealPlanScreen extends ConsumerStatefulWidget {
  final MealPlanResponse? generatedPlan;

  const DetailMealPlanScreen({super.key, this.generatedPlan});

  @override
  ConsumerState<DetailMealPlanScreen> createState() =>
      _DetailMealPlanScreenState();
}

class _DetailMealPlanScreenState extends ConsumerState<DetailMealPlanScreen> {
  late MealPlanResponse? _plan;
  final Set<int> _expandedEntryIds = <int>{};

  @override
  void initState() {
    super.initState();
    _plan = widget.generatedPlan;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan?.plan;
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;
    final userPermissions = authState is AuthenticatedAuthState
        ? authState.user.permissions?.permissions
        : null;

    final actionsState = ref.watch(mealPlanEntryActionsProvider);
    final isLoading = actionsState.status == MealPlanEntryActionStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.approvePlanTitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_plan != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF7D9E87)),
              tooltip: l10n.deletePlanTooltip,
              onPressed: isLoading
                  ? null
                  : () => _showDeletePlanSheet(context, plan!.id),
            ),
        ],
      ),
      body: _plan == null
          ? Center(child: Text(l10n.noPlanDataReceived))
          : SafeArea(
              maintainBottomViewPadding: true,
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan!.planName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1E1B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!isLoading)
                              TextButton(
                                onPressed: () => _showEditDatesPicker(
                                  context,
                                  plan.startDate,
                                  plan.endDate,
                                  plan.id,
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFFE9EFEB),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  l10n.edit.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF576F5F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const DragDropHint(),
                      const SizedBox(height: 16),
                      ...plan.dailyMeals.map(
                        (day) => DaySection(
                          day: day,
                          hideNutritionValues: hideNutritionValues,
                          isLoading: isLoading,
                          isEntryExpanded: (entryId) =>
                              _expandedEntryIds.contains(entryId),
                          onToggleExpanded: _toggleMealExpansion,
                          onDeleteEntry: (entryId) =>
                              _deleteEntry(context, entryId, day, plan),
                          onRegenerateEntry: (entryId, mealType) =>
                              _showRegenerateSheet(
                                context,
                                entryId: entryId,
                                mealType: mealType,
                                userPermissions: userPermissions,
                              ),
                          onSwapRecipe: (entryId) =>
                              _swapRecipe(context, entryId),
                          onChangeEntryDate: (meal, oldDate) =>
                              _showMoveDatePicker(context, meal, oldDate),
                          onMoveEntry: (meal, oldDate, newDate) =>
                              _moveEntry(context, meal, oldDate, newDate),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                  if (isLoading)
                    const Positioned.fill(
                      child: AbsorbPointer(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: _plan == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                    onPressed: () => SaveIngredientsFlow.show(
                      context: context,
                      ref: ref,
                      planId: plan!.id,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF576F5F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.done.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    int entryId,
    DailyMeals day,
    MealPlan plan,
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
    if (confirmed != true || !mounted) return;

    await ref.read(mealPlanEntryActionsProvider.notifier).deleteEntry(entryId);

    if (!mounted) return;
    final state = ref.read(mealPlanEntryActionsProvider);
    if (state.status == MealPlanEntryActionStatus.success) {
      final updatedDays = _plan!.plan.dailyMeals.map((d) {
        if (d.date != day.date) return d;
        final updatedMeals = d.meals
            .where((m) => m.entryId != entryId)
            .toList();
        return DailyMeals(date: d.date, meals: updatedMeals);
      }).toList();
      setState(() {
        _plan = MealPlanResponse(
          plan: MealPlan(
            id: _plan!.plan.id,
            planName: _plan!.plan.planName,
            startDate: _plan!.plan.startDate,
            endDate: _plan!.plan.endDate,
            dailyMeals: updatedDays,
          ),
          meta: _plan!.meta,
        );
      });
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    } else if (state.status == MealPlanEntryActionStatus.error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ??
                AppLocalizations.of(context).genericDeleteError,
          ),
        ),
      );
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    }
  }

  Future<void> _moveEntry(
    BuildContext context,
    MealEntry meal,
    DateTime oldDate,
    DateTime newDate,
  ) async {
    final normalizedNewDate = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
    );
    if (_isSameDate(oldDate, normalizedNewDate)) return;

    await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .moveEntryToDate(meal.entryId, normalizedNewDate);

    if (!mounted) return;
    final state = ref.read(mealPlanEntryActionsProvider);
    if (state.status == MealPlanEntryActionStatus.success) {
      var targetDayFound = false;
      final updatedDays = <DailyMeals>[];

      for (final day in _plan!.plan.dailyMeals) {
        if (_isSameDate(day.date, oldDate)) {
          updatedDays.add(
            DailyMeals(
              date: day.date,
              meals: day.meals.where((m) => m.entryId != meal.entryId).toList(),
            ),
          );
          continue;
        }

        if (_isSameDate(day.date, normalizedNewDate)) {
          targetDayFound = true;
          updatedDays.add(
            DailyMeals(
              date: day.date,
              meals: [
                ...day.meals.where((m) => m.entryId != meal.entryId),
                meal,
              ],
            ),
          );
          continue;
        }

        updatedDays.add(day);
      }

      if (!targetDayFound) {
        updatedDays.add(DailyMeals(date: normalizedNewDate, meals: [meal]));
      }

      updatedDays.sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _plan = MealPlanResponse(
          plan: MealPlan(
            id: _plan!.plan.id,
            planName: _plan!.plan.planName,
            startDate: _plan!.plan.startDate,
            endDate: _plan!.plan.endDate,
            dailyMeals: updatedDays,
          ),
          meta: _plan!.meta,
        );
      });
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    } else if (state.status == MealPlanEntryActionStatus.error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? AppLocalizations.of(context).genericMoveError,
          ),
        ),
      );
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
    }
  }

  Future<void> _showMoveDatePicker(
    BuildContext context,
    MealEntry meal,
    DateTime oldDate,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: oldDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );

    if (pickedDate == null || !context.mounted) return;
    await _moveEntry(context, meal, oldDate, pickedDate);
  }

  Future<void> _showEditDatesPicker(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
    int planId,
  ) async {
    final result = await showModalBottomSheet<Map<String, DateTime>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DateSelectionSheet(
        initialStartDate: startDate,
        initialEndDate: endDate,
      ),
    );

    if (result == null || !context.mounted) return;

    final newStartDate = result['start']!;
    final newEndDate = result['end']!;

    final String startDateStr =
        '${newStartDate.year}-${newStartDate.month.toString().padLeft(2, '0')}-${newStartDate.day.toString().padLeft(2, '0')}';
    final String endDateStr =
        '${newEndDate.year}-${newEndDate.month.toString().padLeft(2, '0')}-${newEndDate.day.toString().padLeft(2, '0')}';

    final updateResult = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .updateMealPlanDates(planId, startDateStr, endDateStr);

    if (updateResult == null) {
      if (!context.mounted) return;
      final state = ref.read(mealPlanEntryActionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? AppLocalizations.of(context).genericError,
          ),
        ),
      );
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
      return;
    }

    if (!context.mounted) return;

    // Shift entries locally
    final shiftedDays = updateResult.shiftedDays;
    final updatedDays = <DailyMeals>[];
    for (final day in _plan!.plan.dailyMeals) {
      final shiftedDate = day.date.add(Duration(days: shiftedDays));
      final shiftedMeals = day.meals.map((m) {
        return MealEntry(
          entryId: m.entryId,
          mealType: m.mealType,
          name: m.name,
          recipe: m.recipe,
          description: m.description,
          servings: m.servings,
          calories: m.calories,
          proteinGrams: m.proteinGrams,
          carbsGrams: m.carbsGrams,
          fatsGrams: m.fatsGrams,
          categories: m.categories,
          status: m.status,
        );
      }).toList();
      updatedDays.add(DailyMeals(date: shiftedDate, meals: shiftedMeals));
    }

    updatedDays.sort((a, b) => a.date.compareTo(b.date));

    setState(() {
      _plan = MealPlanResponse(
        plan: MealPlan(
          id: _plan!.plan.id,
          planName: _plan!.plan.planName,
          startDate: newStartDate,
          endDate: newEndDate,
          dailyMeals: updatedDays,
        ),
        meta: _plan!.meta,
      );
    });

    ref.read(mealPlanEntryActionsProvider.notifier).reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).datesUpdatedSuccess)),
    );
  }

  void _toggleMealExpansion(int entryId) {
    setState(() {
      if (_expandedEntryIds.contains(entryId)) {
        _expandedEntryIds.remove(entryId);
      } else {
        _expandedEntryIds.add(entryId);
      }
    });
  }

  Future<void> _swapRecipe(BuildContext context, int entryId) async {
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

    final updated = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .swapRecipe(entryId, selectedRecipeId);

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
      ref.read(mealPlanEntryActionsProvider.notifier).reset();
      return;
    }

    if (!context.mounted) return;

    // Update locally
    final updatedDays = _plan!.plan.dailyMeals.map((d) {
      final updatedMeals = d.meals.map((m) {
        if (m.entryId != entryId) return m;
        final updatedName = updated.name.trim().isEmpty ? m.name : updated.name;
        final updatedDescription =
            (updated.description != null &&
                updated.description!.trim().isNotEmpty)
            ? updated.description
            : m.description;
        final updatedInstructions =
            (updated.instructions != null &&
                updated.instructions!.trim().isNotEmpty)
            ? updated.instructions!
            : m.recipe.instructions;
        final updatedIngredients = updated.ingredients.isNotEmpty
            ? updated.ingredients
                  .map(
                    (i) => Ingredient(
                      name: i.name,
                      quantity: i.quantity ?? 0.0,
                      unit: i.unit ?? '',
                      category: i.category ?? '',
                    ),
                  )
                  .toList()
            : m.recipe.ingredients;
        final updatedCategories = updated.categories.isNotEmpty
            ? updated.categories
            : m.categories;

        return MealEntry(
          entryId: updated.entryId,
          mealType: updated.mealType ?? m.mealType,
          name: updatedName,
          description: updatedDescription,
          servings: updated.servings ?? m.servings,
          calories: updated.calories ?? m.calories,
          proteinGrams: updated.proteinGrams ?? m.proteinGrams,
          carbsGrams: updated.carbsGrams ?? m.carbsGrams,
          fatsGrams: updated.fatsGrams ?? m.fatsGrams,
          categories: updatedCategories,
          status: updated.status ?? m.status,
          recipe: Recipe(
            name: updatedName,
            description: updatedDescription ?? m.recipe.description,
            instructions: updatedInstructions,
            servings: updated.servings ?? m.recipe.servings,
            calories: updated.calories ?? m.recipe.calories,
            proteinGrams: updated.proteinGrams ?? m.recipe.proteinGrams,
            carbsGrams: updated.carbsGrams ?? m.recipe.carbsGrams,
            fatsGrams: updated.fatsGrams ?? m.recipe.fatsGrams,
            ingredients: updatedIngredients,
            prepTimeMinutes: m.recipe.prepTimeMinutes,
            cookTimeMinutes: m.recipe.cookTimeMinutes,
          ),
        );
      }).toList();
      return DailyMeals(date: d.date, meals: updatedMeals);
    }).toList();

    setState(() {
      _plan = MealPlanResponse(
        plan: MealPlan(
          id: _plan!.plan.id,
          planName: _plan!.plan.planName,
          startDate: _plan!.plan.startDate,
          endDate: _plan!.plan.endDate,
          dailyMeals: updatedDays,
        ),
        meta: _plan!.meta,
      );
    });
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
  }

  Future<void> _showRegenerateSheet(
    BuildContext context, {
    required int entryId,
    required String mealType,
    required PermissionDetails? userPermissions,
  }) async {
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
        actionsNotifier: ref.read(mealPlanEntryActionsProvider.notifier),
      ),
    );

    if (updated == null || !mounted) return;

    // Update locally
    final updatedDays = _plan!.plan.dailyMeals.map((d) {
      final updatedMeals = d.meals.map((m) {
        if (m.entryId != entryId) return m;
        return MealEntry(
          entryId: updated.entryId,
          mealType: updated.mealType ?? mealType,
          name: updated.name,
          description: updated.description,
          servings: updated.servings,
          calories: updated.calories,
          proteinGrams: updated.proteinGrams,
          carbsGrams: updated.carbsGrams,
          fatsGrams: updated.fatsGrams,
          categories: updated.categories,
          status: updated.status,
          recipe: Recipe(
            name: updated.name,
            description: updated.description ?? '',
            instructions: updated.instructions ?? '',
            servings: updated.servings,
            calories: updated.calories,
            proteinGrams: updated.proteinGrams,
            carbsGrams: updated.carbsGrams,
            fatsGrams: updated.fatsGrams,
            ingredients: updated.ingredients
                .map(
                  (i) => Ingredient(
                    name: i.name,
                    quantity: i.quantity ?? 0.0,
                    unit: i.unit ?? '',
                    category: i.category ?? '',
                  ),
                )
                .toList(),
          ),
        );
      }).toList();
      return DailyMeals(date: d.date, meals: updatedMeals);
    }).toList();

    setState(() {
      _plan = MealPlanResponse(
        plan: MealPlan(
          id: _plan!.plan.id,
          planName: _plan!.plan.planName,
          startDate: _plan!.plan.startDate,
          endDate: _plan!.plan.endDate,
          dailyMeals: updatedDays,
        ),
        meta: _plan!.meta,
      );
    });
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
  }

  Future<void> _showDeletePlanSheet(BuildContext context, int planId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeletePlanSheet(
        planId: planId,
        actionsNotifier: ref.read(mealPlanEntryActionsProvider.notifier),
        onDeleted: () {
          if (mounted) context.go('/home');
        },
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
