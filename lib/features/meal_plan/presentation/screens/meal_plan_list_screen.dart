import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/providers/grocery_actions_provider.dart';
import 'package:meal_plan_app/features/grocery_list/presentation/widgets/select_grocery_list_sheet.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/widgets/detail_meal_plan/plan_actions_sheet.dart';

class MealPlanListScreen extends ConsumerWidget {
  const MealPlanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(mealPlansProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF5C7861), size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.myPlansTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFF5C7861), size: 24),
            onPressed: () => context.go('/meal-plan'),
            tooltip: l10n.mealPlanTitle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: plansAsync.when(
        data: (plansList) => plansList.isEmpty 
            ? null 
            : FloatingActionButton.extended(
                onPressed: () => context.push('/meal-plan/new'),
                backgroundColor: const Color(0xFF7BA082),
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  l10n.createNewPlanTooltip,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
        loading: () => null,
        error: (_, __) => null,
      ),
      body: plansAsync.when(
        data: (plansList) {
          if (plansList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF94A3B8).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 64,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noPlansAddedTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noPlansAddedMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => context.push('/meal-plan/new'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.createNewPlanTooltip),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C7861),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          int getDaysDifference(DateTime start, DateTime end) {
            final st = DateTime(start.year, start.month, start.day);
            final ed = DateTime(end.year, end.month, end.day);
            return ed.difference(st).inDays + 1;
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final sortedPlans = List<MealPlanSummary>.from(plansList);
          sortedPlans.sort((a, b) {
            final aEnd = DateTime(a.endDate.year, a.endDate.month, a.endDate.day);
            final bEnd = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
            final aIsFuture = aEnd.isAfter(today) || aEnd.isAtSameMomentAs(today);
            final bIsFuture = bEnd.isAfter(today) || bEnd.isAtSameMomentAs(today);
            if (aIsFuture && !bIsFuture) return -1;
            if (!aIsFuture && bIsFuture) return 1;
            return b.endDate.compareTo(a.endDate);
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mealPlansProvider);
            },
            color: const Color(0xFF5C7861),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: sortedPlans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final plan = sortedPlans[index];
                return _MealPlanCard(
                  key: ValueKey(plan.id),
                  plan: plan,
                  daysCount: getDaysDifference(plan.startDate, plan.endDate),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5C7861)),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).genericError,
                style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(mealPlansProvider),
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).tryAgain),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5C7861),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPlanCard extends ConsumerWidget {
  final MealPlanSummary plan;
  final int daysCount;

  const _MealPlanCard({
    super.key,
    required this.plan,
    required this.daysCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).toString();
    final DateFormat formatter = DateFormat('d MMM', localeStr);
    final DateFormat yearFormatter = DateFormat('d MMM yyyy', localeStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/meal-plan/${plan.id}'),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: plan.generatedByAi ? const Color(0xFFE8F0E8) : const Color(0xFFF4F7F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            plan.generatedByAi ? Icons.auto_awesome_rounded : Icons.person_rounded,
                            size: 14,
                            color: plan.generatedByAi ? const Color(0xFF4C6B4F) : const Color(0xFF4A729A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            plan.generatedByAi ? l10n.planBadgeAI : l10n.planBadgeCustom,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: plan.generatedByAi ? const Color(0xFF4C6B4F) : const Color(0xFF4A729A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () => _showPlanActionsSheet(context, ref, l10n),
                        icon: const Icon(Icons.more_vert_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        splashRadius: 24,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  plan.planName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF002140),
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formatter.format(plan.startDate).toUpperCase()} - ${yearFormatter.format(plan.endDate).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPlanActionsSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: PlanActionsSheet(plan: plan),
          ),
        );
      },
    );
  }
}
