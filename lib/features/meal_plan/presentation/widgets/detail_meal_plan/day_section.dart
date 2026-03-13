import 'package:flutter/material.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class DragMealData {
  final MealEntry meal;
  final DateTime date;
  const DragMealData(this.meal, this.date);
}

class DaySection extends StatelessWidget {
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

  const DaySection({
    super.key,
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
    return DragTarget<DragMealData>(
      onAcceptWithDetails: (details) {
        final data = details.data;
        onMoveEntry(data.meal, data.date, day.date);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropping = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatDateDay(day.date).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFA7BFAF),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade100,
                      thickness: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EFEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.mealsCount(day.meals.length).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF576F5F),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
                      (meal) => LongPressDraggable<DragMealData>(
                        data: DragMealData(meal, day.date),
                        feedback: SizedBox(
                          width: MediaQuery.of(context).size.width - 60,
                          child: Material(
                            color: Colors.transparent,
                            child: Opacity(
                              opacity: 0.8,
                              child: MealTile(
                                meal: meal,
                                date: day.date,
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
                          child: MealTile(
                            meal: meal,
                            date: day.date,
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
                        child: MealTile(
                          meal: meal,
                          date: day.date,
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

class MealTile extends StatelessWidget {
  final MealEntry meal;
  final DateTime date;
  final bool hideNutritionValues;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onDelete;
  final VoidCallback onRegenerate;
  final VoidCallback onSwapRecipe;
  final Future<void> Function() onChangeDate;

  const MealTile({
    super.key,
    required this.meal,
    required this.date,
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
    final mealTypeLbl = mealTypeLabel(l10n, meal.mealType).toUpperCase();
    final totalTimeMinutes =
        (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    return InkWell(
      onTap: onToggleExpanded,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F1F1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Drag Handle Area
              Container(
                width: 32,
                color: const Color(0xFFF8F9F8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (_) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealTypeLbl,
                        style: const TextStyle(
                          color: Color(0xFFA7BFAF),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1E1B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (totalTimeMinutes > 0) ...[
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 14,
                              color: const Color(0xFF7D9E87).withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.minutesShortWithPlaceholder(
                                totalTimeMinutes.toString(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF576F5F),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (recipe.servings != null) ...[
                            Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: const Color(0xFF7D9E87).withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.servingsLabel(recipe.servings.toString()),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF576F5F),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            onPressed: () => showMealActionsSheet(
                              context,
                              meal: meal,
                              date: date,
                              onDelete: onDelete,
                              onRegenerate: onRegenerate,
                              onSwapRecipe: onSwapRecipe,
                              onChangeDate: onChangeDate,
                            ),
                            icon: const Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...meal.categories.map(
                            (category) => CategoryTag(label: category),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const Divider(height: 24),
                        if (recipe.description.trim().isNotEmpty) ...[
                          Text(
                            recipe.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          l10n.ingredientsTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        ...recipe.ingredients.map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${ingredient.name} - ${ingredient.quantity} ${ingredient.unit}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTag extends StatelessWidget {
  final String label;
  const CategoryTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF576F5F),
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

Future<void> showMealActionsSheet(
  BuildContext context, {
  required MealEntry meal,
  required DateTime date,
  required VoidCallback onDelete,
  required VoidCallback onRegenerate,
  required VoidCallback onSwapRecipe,
  required Future<void> Function() onChangeDate,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              ActionRow(
                icon: Icons.refresh_rounded,
                label: l10n.regenerateRecipeAction,
                iconBgColor: const Color(0xFFF4F7F5),
                iconColor: const Color(0xFF576F5F),
                onTap: () {
                  Navigator.pop(context);
                  onRegenerate();
                },
              ),
              const Divider(color: Color(0xFFF1F1F1)),
              ActionRow(
                icon: Icons.swap_horiz_rounded,
                label: l10n.swapFavoriteAction,
                iconBgColor: const Color(0xFFF4F7F5),
                iconColor: const Color(0xFF576F5F),
                onTap: () {
                  Navigator.pop(context);
                  onSwapRecipe();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? const Color(0xFFE57373) : const Color(0xFF1A1E1B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String mealTypeLabel(AppLocalizations l10n, String mealType) {
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

String formatDateDay(DateTime date) {
  final weekdays = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  final months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${weekdays[date.weekday - 1]} ${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]}';
}
