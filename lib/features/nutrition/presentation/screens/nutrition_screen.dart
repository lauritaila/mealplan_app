import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_provider.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/gamification_achievements.dart';
import '../widgets/hero_consistency_ring.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/weekly_averages_card.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(currentNutritionSummaryProvider);
    final daysFilter = ref.watch(nutritionDaysFilterProvider);
    final profileState = ref.watch(profileProvider);
    final hideNutritionValues = profileState.hideNutritionValues;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionTitle),
        centerTitle: false,
        actions: [
          PopupMenuButton<int>(
            initialValue: daysFilter,
            onSelected: (days) {
              ref.read(nutritionDaysFilterProvider.notifier).setDays(days);
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text(l10n.nutritionFilterDaily)),
              PopupMenuItem(value: 7, child: Text(l10n.nutritionFilterWeekly)),
              PopupMenuItem(value: 30, child: Text(l10n.nutritionFilterMonthly)),
            ],
          ),
        ],
      ),
      body: nutritionAsync.when(
        data: (summary) {
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              return ref.refresh(currentNutritionSummaryProvider.future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroConsistencyRing(
                    consistencyScore: summary.weeklyAverage.consistencyScore,
                  ),
                  const SizedBox(height: 32),
                  WeeklyActivityChart(
                    dailyTotals: summary.dailyTotals,
                    hideNutritionValues: hideNutritionValues,
                  ),
                  const SizedBox(height: 32),
                  WeeklyAveragesCard(
                    weeklyAverage: summary.weeklyAverage,
                    hideNutritionValues: hideNutritionValues,
                  ),
                  const SizedBox(height: 32),
                  const GamificationAchievements(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.nutritionErrorLoading,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(currentNutritionSummaryProvider.future);
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
