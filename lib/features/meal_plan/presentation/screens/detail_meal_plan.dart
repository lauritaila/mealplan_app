import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/swap_recipe_sheet.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
        title: Text(l10n.approvePlanTitle),
        actions: [
          if (_plan != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        plan!.planName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      const _DragDropHint(),
                      const SizedBox(height: 16),
                      ...plan.dailyMeals.map(
                        (day) => _DaySection(
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
              minimum: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l10n.done),
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
      // Remove the meal entry locally from the plan
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

    if (selectedRecipeId == null || !mounted) return;

    final updated = await ref
        .read(mealPlanEntryActionsProvider.notifier)
        .swapRecipe(entryId, selectedRecipeId);

    if (updated == null || !mounted) return;

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RegenerateEntrySheet(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DeletePlanSheet(
        planId: planId,
        actionsNotifier: ref.read(mealPlanEntryActionsProvider.notifier),
        onDeleted: () {
          if (mounted) context.go('/home');
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _DragMealData {
  final MealEntry meal;
  final DateTime date;
  const _DragMealData(this.meal, this.date);
}

// ---------------------------------------------------------------------------
// _DragDropHint
// ---------------------------------------------------------------------------
class _DragDropHint extends StatelessWidget {
  const _DragDropHint();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.touch_app,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.dragDropHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Tooltip(
            message: l10n.dragDropTooltip,
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DaySection
// ---------------------------------------------------------------------------
class _DaySection extends StatelessWidget {
  final DailyMeals day;
  final bool hideNutritionValues;
  final bool isLoading;
  final bool Function(int entryId) isEntryExpanded;
  final void Function(int entryId) onToggleExpanded;
  final void Function(int entryId) onDeleteEntry;
  final void Function(int entryId, String mealType) onRegenerateEntry;
  final void Function(int entryId) onSwapRecipe;
  final Future<void> Function(MealEntry meal, DateTime oldDate)
  onChangeEntryDate;
  final void Function(MealEntry meal, DateTime oldDate, DateTime newDate)
  onMoveEntry;

  const _DaySection({
    required this.day,
    required this.hideNutritionValues,
    required this.isLoading,
    required this.isEntryExpanded,
    required this.onToggleExpanded,
    required this.onDeleteEntry,
    required this.onRegenerateEntry,
    required this.onSwapRecipe,
    required this.onChangeEntryDate,
    required this.onMoveEntry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DragTarget<_DragMealData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        onMoveEntry(data.meal, data.date, day.date);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropping = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(day.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.mealsCount(day.meals.length),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isDropping
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ...day.meals.map(
                      (meal) => LongPressDraggable<_DragMealData>(
                        data: _DragMealData(meal, day.date),
                        feedback: SizedBox(
                          width: MediaQuery.of(context).size.width - 60,
                          child: Material(
                            color: Colors.transparent,
                            child: Opacity(
                              opacity: 0.8,
                              child: _MealTile(
                                meal: meal,
                                hideNutritionValues: hideNutritionValues,
                                isLoading: false,
                                isExpanded: false,
                                onToggleExpanded: () {},
                                onDelete: () {},
                                onRegenerate: () {},
                                onSwapRecipe: () {},
                                onChangeDate: () async {},
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _MealTile(
                            meal: meal,
                            hideNutritionValues: hideNutritionValues,
                            isLoading: isLoading,
                            isExpanded: isEntryExpanded(meal.entryId),
                            onToggleExpanded: () =>
                                onToggleExpanded(meal.entryId),
                            onDelete: () => onDeleteEntry(meal.entryId),
                            onRegenerate: () =>
                                onRegenerateEntry(meal.entryId, meal.mealType),
                            onSwapRecipe: () => onSwapRecipe(meal.entryId),
                            onChangeDate: () =>
                                onChangeEntryDate(meal, day.date),
                          ),
                        ),
                        child: _MealTile(
                          meal: meal,
                          hideNutritionValues: hideNutritionValues,
                          isLoading: isLoading,
                          isExpanded: isEntryExpanded(meal.entryId),
                          onToggleExpanded: () =>
                              onToggleExpanded(meal.entryId),
                          onDelete: () => onDeleteEntry(meal.entryId),
                          onRegenerate: () =>
                              onRegenerateEntry(meal.entryId, meal.mealType),
                          onSwapRecipe: () => onSwapRecipe(meal.entryId),
                          onChangeDate: () => onChangeEntryDate(meal, day.date),
                        ),
                      ),
                    ),
                    if (day.meals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.emptyDayDropText,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _MealTile (detail view for the plan approval screen)
// ---------------------------------------------------------------------------
class _MealTile extends StatelessWidget {
  final MealEntry meal;
  final bool hideNutritionValues;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onDelete;
  final VoidCallback onRegenerate;
  final VoidCallback onSwapRecipe;
  final Future<void> Function() onChangeDate;

  const _MealTile({
    required this.meal,
    required this.hideNutritionValues,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onDelete,
    required this.onRegenerate,
    required this.onSwapRecipe,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = meal.recipe;
    final l10n = AppLocalizations.of(context);
    final mealTypeLabel = _mealTypeLabel(l10n, meal.mealType);
    final totalTimeMinutes =
        (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mealTypeLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      enabled: !isLoading,
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) async {
                        if (value == 'delete') onDelete();
                        if (value == 'regenerate') onRegenerate();
                        if (value == 'swap') onSwapRecipe();
                        if (value == 'change_date') await onChangeDate();
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
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
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
              ],
            ),

            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (totalTimeMinutes > 0)
                  _Chip(
                    label: l10n.minutesShortWithPlaceholder(
                      totalTimeMinutes.toString(),
                    ),
                  ),
                if (recipe.servings != null)
                  _Chip(label: l10n.servingsLabel(recipe.servings.toString())),
                ...meal.categories.map((category) => _Chip(label: category)),
              ],
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onToggleExpanded,
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(
                  isExpanded ? l10n.hideDetailsLabel : l10n.viewDetailsLabel,
                ),
              ),
            ),

            if (isExpanded) ...[
              const Divider(height: 8),
              if (recipe.description.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                l10n.ingredientsTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...recipe.ingredients.map(
                (ingredient) => Text(
                  '• ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit} (${ingredient.category})',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
              if (recipe.instructions.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.instructionsTitle,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.instructions,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Chip
// ---------------------------------------------------------------------------
class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

// ---------------------------------------------------------------------------
// _RegenerateEntrySheet
// ---------------------------------------------------------------------------
class _RegenerateEntrySheet extends StatefulWidget {
  final int entryId;
  final String mealType;
  final PermissionDetails? userPermissions;
  final MealPlanEntryActions actionsNotifier;

  const _RegenerateEntrySheet({
    required this.entryId,
    required this.mealType,
    required this.userPermissions,
    required this.actionsNotifier,
  });

  @override
  State<_RegenerateEntrySheet> createState() => _RegenerateEntrySheetState();
}

class _RegenerateEntrySheetState extends State<_RegenerateEntrySheet> {
  final _descController = TextEditingController();
  int? _selectedMaxTime;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final times = widget.userPermissions?.mealPlanTime;
    if (times != null && times.isNotEmpty) {
      _selectedMaxTime = times.last; // default to the largest
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
            // Handle bar
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

// ---------------------------------------------------------------------------
// _DeletePlanSheet
// ---------------------------------------------------------------------------
class _DeletePlanSheet extends StatefulWidget {
  final int planId;
  final MealPlanEntryActions actionsNotifier;
  final VoidCallback onDeleted;

  const _DeletePlanSheet({
    required this.planId,
    required this.actionsNotifier,
    required this.onDeleted,
  });

  @override
  State<_DeletePlanSheet> createState() => _DeletePlanSheetState();
}

class _DeletePlanSheetState extends State<_DeletePlanSheet> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Handle bar
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
              l10n.deletePlanSheetTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.deletePlanSheetWarning,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.deletePlanSheetReasonLabel,
                hintText: l10n.deletePlanSheetReasonHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _isLoading ? null : _confirm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.deletePlanSheetConfirmAction),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    await widget.actionsNotifier.deletePlan(
      widget.planId,
      deleteDescription: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onDeleted();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _mealTypeLabel(AppLocalizations l10n, String mealType) {
  switch (mealType.toLowerCase()) {
    case 'breakfast':
    case 'desayuno':
      return l10n.mealTypeBreakfast;
    case 'lunch':
    case 'almuerzo':
      return l10n.mealTypeLunch;
    case 'dinner':
    case 'cena':
      return l10n.mealTypeDinner;
    case 'snack':
    case 'merienda':
      return l10n.mealTypeSnack;
    default:
      return mealType;
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
