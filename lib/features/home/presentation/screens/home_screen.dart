import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/home/presentation/providers/home_provider.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/daily_nutrition_summary.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/grace_welcome_dialog.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/home_empty_plan_widget.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/home_premium_banner.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/home_week_progress_indicator.dart';
import 'package:meal_plan_app/features/home/presentation/widgets/today_meal_card.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
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
            builder: (_) => const GraceWelcomeDialog(),
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
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: customColors.textDarkBlue,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.homeTodayPlanReady,
                            style: textTheme.bodyMedium?.copyWith(
                              color: customColors.slateGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HomeWeekProgressIndicator(nutritionAsync: nutritionAsync),
                  ],
                ),
                const SizedBox(height: 24),
        
                // Go Premium Banner (If Free)
                if (homeState.isFreePlan) ...[
                  const HomePremiumBanner(),
                  const SizedBox(height: 24),
                ],
        
                // Recipes Section
                mealEntriesAsync.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Column(
                        children: [
                          HomeEmptyPlanWidget(),
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
                                  TodayMealCard(
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
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: customColors.darkSage)),
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
                const HomeQuickActions(),
        
                // Daily Nutrition Section
                if (!hideNutritionValues)
                  DailyNutritionSummary(nutritionAsync: nutritionAsync),
        
                // Generate Plan Button (only show if there is a plan)
                if (mealEntriesAsync.valueOrNull?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CustomFilledButton(
                      text: l10n.generateNewPlan,
                      icon: Icons.refresh,
                      onPressed: () => context.push('/meal-plan/new'),
                      buttonColor: Colors.transparent,
                      textColor: customColors.darkSage,
                      // Note: We need a CustomOutlinedButton really. 
                      // For now I'll use CustomFilledButton with transparent bg if it supports it well
                      // Actually I'll just use a normal OutlinedButton for now but style it properly.
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
