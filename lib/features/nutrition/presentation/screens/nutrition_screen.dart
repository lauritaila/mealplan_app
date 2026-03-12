import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import '../providers/nutrition_provider.dart';
import '../widgets/nutrition_filters_sheet.dart';
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.nutritionTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: customColors.textDarkBlue),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (context) => const NutritionFiltersSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroConsistencyRing(
                    consistencyScore: summary.weeklyAverage.consistencyScore,
                  ),
                  const SizedBox(height: 40),
                  WeeklyActivityChart(
                    dailyTotals: summary.dailyTotals,
                    hideNutritionValues: hideNutritionValues,
                  ),
                  const SizedBox(height: 40),
                  WeeklyAveragesCard(
                    weeklyAverage: summary.weeklyAverage,
                    hideNutritionValues: hideNutritionValues,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: customColors.slateGrey?.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                l10n.nutritionErrorLoading,
                style: textTheme.bodyLarge?.copyWith(color: customColors.slateGrey),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(currentNutritionSummaryProvider.future);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: customColors.darkSage,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.retry, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
