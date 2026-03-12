import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/home/presentation/providers/home_provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/entities/day_meal_entry.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class _WeekProgressIndicator extends StatelessWidget {
  final AsyncValue nutritionAsync;
  const _WeekProgressIndicator({required this.nutritionAsync});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.homeWeekLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade300,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 8),
          nutritionAsync.when(
            data: (summary) {
              final score = summary.weeklyAverage.consistencyScore;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 5,
                      backgroundColor: const Color(0xFFE8F0E8),
                      color: const Color(0xFF4C6B4F),
                    ),
                  ),
                  Text(
                    '${score.toInt()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB4A17B),
                        ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            error: (error, stack) => const Center(child: Icon(Icons.error_outline)),
          ),
        ],
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _PremiumBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8), // Very pale green
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium, 
              color: Color(0xFF7BA082), 
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.goPremiumUnlockMorePlans,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4A5F50),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go(
              '/premium',
              extra: {
                'title': l10n.goPremiumTitle,
                'message': l10n.freePlanLimitedGenerations,
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF819F86), // Muted green from screenshot
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(l10n.premiumLearnMore, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewStateProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    // Watch Nutrition summary for Consistency
    final nutritionAsync = ref.watch(currentNutritionSummaryProvider);

    // Watch today's meal entries
    final selectedDate = ref.watch(selectedMealPlanDayProvider);
    final mealEntriesAsync = ref.watch(mealPlanDayEntriesProvider(selectedDate));

    ref.listen(homeShowGraceWelcomeProvider, (previous, next) {
      if (next == true && previous != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) return;
          await showDialog<void>(
            context: context,
            builder: (_) => const _GraceWelcomeDialog(),
          );
          if (context.mounted) {
            ref.read(authProvider.notifier).consumeGraceWelcome();
          }
        });
      }
    });

    String userName = '';
    bool hideNutritionValues = false;
    if (authState is AuthenticatedAuthState) {
      userName = authState.user.name ?? '';
      hideNutritionValues = authState.user.configurations?['hideNutritionValues'] == true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and Week Progress Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (userName.isNotEmpty)
                            Text(
                              l10n.greeting(userName.split(' ')[0]),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF002140),
                                  ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.homeTodayPlanReady,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    _WeekProgressIndicator(nutritionAsync: nutritionAsync),
                  ],
                ),
                const SizedBox(height: 24),
        
                // Go Premium Banner (If Free)
                if (homeState.isFreePlan) ...[
                  _PremiumBanner(l10n: l10n),
                  const SizedBox(height: 24),
                ],
        
                // Recipes Section
                mealEntriesAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Column(
                        children: [
                          _EmptyPlanWidget(l10n: l10n),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0; i < entries.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 16),
                                  _RecipeCard(
                                    entry: entries[i],
                                    totalEntries: entries.length,
                                    selectedDate: selectedDate,
                                    hideNutritionValues: hideNutritionValues,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
                _QuickActionsWidget(mealEntriesAsync: mealEntriesAsync),
        
                // Daily Nutrition Section
                if (!hideNutritionValues)
                  _DailyNutritionSection(nutritionAsync: nutritionAsync),
        
                // Action Buttons Section
                
                // Generate Plan Button (only show if there is a plan)
                if (mealEntriesAsync.valueOrNull?.isNotEmpty == true)
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/meal-plan/new'),
                      icon: const Icon(Icons.refresh, size: 24),
                      label: Text(
                        l10n.generateNewPlan,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4C6B4F),
                        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final DayMealEntry entry;
  final int totalEntries;
  final DateTime selectedDate;
  final bool hideNutritionValues;

  const _RecipeCard({
    required this.entry,
    required this.totalEntries,
    required this.selectedDate,
    required this.hideNutritionValues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isCompleted = entry.status == 'completed';
    final isSkipped = entry.status?.toLowerCase() == 'skipped' || 
                      entry.status?.toLowerCase() == 'skiped';
    
    final width = totalEntries == 1 ? MediaQuery.of(context).size.width - 48 : MediaQuery.of(context).size.width * 0.85;

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _getMealIcon(entry.mealType),
              ),
              const SizedBox(height: 12),
              Text(
                (entry.mealType ?? 'MEAL').toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade300,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSkipped ? Colors.grey : const Color(0xFF002140),
                  decoration: isSkipped ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!hideNutritionValues) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniMacroBadge(label: l10n.metricProtein, value: '${entry.proteinGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.metricCarbsShort, value: '${entry.carbsGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.metricFat, value: '${entry.fatsGrams?.toInt() ?? 0}g'),
                    _MiniMacroBadge(label: l10n.kcalLabel, value: '${entry.calories?.toInt() ?? 0}'),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (entry.recipeId > 0) {
                          context.push('/recipes/${entry.recipeId}?entryId=${entry.entryId}&status=${entry.status}');
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F7F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        l10n.homeViewRecipeShort,
                        style: const TextStyle(color: Color(0xFF002140), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (entry.entryId > 0) {
                          _confirmAndToggleSkip(context, ref, l10n, entry, selectedDate);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5FB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        l10n.homeEatOutAction,
                        style: const TextStyle(color: Color(0xFF5A7AAB), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Checkmark at top right for marking as completed
          if (!isSkipped)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: isCompleted ? null : () => _confirmComplete(context, ref, l10n),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 28,
                  color: isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmComplete(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    if (entry.recipeId <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markCompleteDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.markCompleteQuestion(entry.name)),
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
    
    ref.invalidate(mealPlanDayEntriesProvider(selectedDate));
    ref.read(mealPlanEntryActionsProvider.notifier).reset();
    
    if (result != null) {
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
    }
  }
  // Removed _confirmEatOut and moved logic to shared _confirmAndToggleSkip
}

Future<void> _confirmAndToggleSkip(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  DayMealEntry entry,
  DateTime date,
) async {
  final isSkipped = entry.status?.toLowerCase() == 'skipped' || 
                    entry.status?.toLowerCase() == 'skiped';
  
  bool confirm = true;
  if (!isSkipped) {
    confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeSkipMealQuestion),
        content: Text(l10n.homeSkipMealDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5A7AAB)),
            child: Text(l10n.homeConfirmAction),
          ),
        ],
      ),
    ) ?? false;
  }

  if (confirm != true || !context.mounted) return;
  await ref.read(dayMealEntryStatusUpdateProvider.notifier).toggleSkipped(entry, date);
}

  Widget _getMealIcon(String? type) {
    final lower = type?.toLowerCase() ?? '';
    if (lower.contains('breakfast')) return const Icon(Icons.bakery_dining_outlined, color: Color(0xFF4C6B4F));
    if (lower.contains('lunch')) return const Icon(Icons.soup_kitchen_outlined, color: Color(0xFF4C6B4F));
    if (lower.contains('dinner')) return const Icon(Icons.eco_outlined, color: Color(0xFF4C6B4F));
    if (lower.contains('snack')) return const Icon(Icons.fastfood_outlined, color: Color(0xFF4C6B4F));
    return const Icon(Icons.restaurant_outlined, color: Color(0xFF4C6B4F));
  }

class _MiniMacroBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMacroBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QuickActionsWidget extends ConsumerWidget {
  final AsyncValue<List<DayMealEntry>> mealEntriesAsync;
  const _QuickActionsWidget({required this.mealEntriesAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.favorite,
            iconColor: const Color(0xFF7BA082),
            label: l10n.homeFavoritesAction,
            onTap: () => context.push('/recipes/favorites'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.show_chart,
            iconColor: const Color(0xFF7BA082),
            label: l10n.homeProgressAction,
            onTap: () => context.push('/nutrition'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF002140),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlanWidget extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyPlanWidget({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7F9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 60,
                  color: Color(0xFFC7D3CA),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit_calendar, size: 20, color: Color(0xFF7BA082)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.homeEmptyPlanTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002140),
              ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.homeEmptyPlanMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () => context.push('/meal-plan/new'),
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text(
              l10n.generateNewPlan,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7BA082),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class _DailyNutritionSection extends StatelessWidget {
  final AsyncValue nutritionAsync;
  const _DailyNutritionSection({required this.nutritionAsync});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return nutritionAsync.when(
      data: (summary) {
        final today = summary.todaySummary;
        if (today == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: 
          Card(
            elevation: 0,
            color: Colors.white,
            child:Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NutritionColumnItem(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                label: l10n.metricCalories.toUpperCase(),
                value: '${today.calories.toInt()} kcal',
                target: '',
              ),
              _NutritionColumnItem(
                icon: Icons.fitness_center,
                iconColor: const Color(0xFF4C6B4F),
                label: l10n.metricProtein.toUpperCase(),
                value: '${today.protein.toInt()}g',
                target: '',
              ),
              _NutritionColumnItem(
                icon: Icons.grain,
                iconColor: Colors.amber.shade700,
                label: l10n.metricCarbs.toUpperCase(),
                value: '${today.carbs.toInt()}g',
                target: '',
              ),
              _NutritionColumnItem(
                icon: Icons.water_drop,
                iconColor: Colors.blue.shade300,
                label: l10n.metricFat.toUpperCase(),
                value: '${today.fats.toInt()}g',
                target: '',
              ),
            ],
          ),
        )
        )
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _NutritionColumnItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String target;

  const _NutritionColumnItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F0E8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.blueGrey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002140),
          ),
        ),
      ],
    );
  }
}

class _GraceWelcomeDialog extends StatefulWidget {
  const _GraceWelcomeDialog();

  @override
  State<_GraceWelcomeDialog> createState() => _GraceWelcomeDialogState();
}

class _GraceWelcomeDialogState extends State<_GraceWelcomeDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Decorative background element
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Decorative Icon/Emoji
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🧑‍🍳', // Chef emoji to match meal theme
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    l10n.graceWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    l10n.graceWelcomeMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.continueLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Celebration effect
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.04,
              numberOfParticles: 15,
              gravity: 0.2,
              maxBlastForce: 12,
              minBlastForce: 6,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
                theme.colorScheme.primaryContainer,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
