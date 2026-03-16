import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/meal_plan_cooking_assistant_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class MealPlanCookingAssistantScreen extends ConsumerStatefulWidget {
  final int planId;

  const MealPlanCookingAssistantScreen({super.key, required this.planId});

  @override
  ConsumerState<MealPlanCookingAssistantScreen> createState() => _MealPlanCookingAssistantScreenState();
}

class _MealPlanCookingAssistantScreenState extends ConsumerState<MealPlanCookingAssistantScreen> {
  final PageController _pageController = PageController();
  int _currentStepGlobalIndex = 0;
  final List<CookingStepDto> _allSteps = [];
  final List<CookingScheduleDto> _flatSchedule = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _flattenSteps(MealPlanCookingAssistantResponseDto data) {
    if (_allSteps.isNotEmpty) return;
    for (var day in data.schedule) {
      for (var step in day.steps) {
        _allSteps.add(step);
        _flatSchedule.add(day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final assistantAsync = ref.watch(mealPlanCookingAssistantProvider(widget.planId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: customColors.textDarkBlue),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              l10n.cookingAssistantTitle,
              style: textTheme.titleMedium?.copyWith(
                color: customColors.textDarkBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
            assistantAsync.when(
              data: (data) => Text(
                data.planName,
                style: textTheme.labelSmall?.copyWith(color: customColors.slateGrey),
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: assistantAsync.when(
        data: (data) {
          _flattenSteps(data);
          if (_allSteps.isEmpty) {
            return Center(child: Text(l10n.noCookingSteps));
          }

          return Column(
            children: [
              _buildProgressHeader(customColors, textTheme, l10n),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _allSteps.length,
                  onPageChanged: (index) => setState(() => _currentStepGlobalIndex = index),
                  itemBuilder: (context, index) {
                    final step = _allSteps[index];
                    final dayInfo = _flatSchedule[index];
                    return _buildStepDetail(step, dayInfo, customColors, textTheme, l10n);
                  },
                ),
              ),
              _buildNavigationFooter(customColors, textTheme, l10n),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildProgressHeader(AppCustomColors customColors, TextTheme textTheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStepGlobalIndex + 1) / _allSteps.length,
            backgroundColor: customColors.chartTabBackground,
            color: customColors.darkSage,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.stepOf(_currentStepGlobalIndex + 1, _allSteps.length),
                style: textTheme.labelMedium?.copyWith(color: customColors.slateGrey, fontWeight: FontWeight.bold),
              ),
              Text(
                '${((_currentStepGlobalIndex + 1) / _allSteps.length).toStringAsFixed(0)}%',
                style: textTheme.labelMedium?.copyWith(color: customColors.darkSage, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDetail(CookingStepDto step, CookingScheduleDto dayInfo, AppCustomColors customColors, TextTheme textTheme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: customColors.chartTabBackground?.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.restaurant, color: customColors.darkSage, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayInfo.recipeName,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: customColors.textDarkBlue),
                    ),
                    Text(
                      '${dayInfo.mealDate} • ${dayInfo.mealType}',
                      style: textTheme.labelSmall?.copyWith(color: customColors.slateGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          step.instruction,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: customColors.textDarkBlue,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        if (step.ingredientsUsed.isNotEmpty) ...[
          _buildSectionHeader(Icons.shopping_basket_outlined, l10n.ingredientsTitle, customColors, textTheme),
          const SizedBox(height: 12),
          ...step.ingredientsUsed.map((ing) => _buildInfoCard(ing.name, '${ing.quantity} ${ing.unit}', customColors, textTheme)),
          const SizedBox(height: 24),
        ],
        if (step.toolsNeeded.isNotEmpty) ...[
          _buildSectionHeader(Icons.handyman_outlined, l10n.cookingToolsLabel, customColors, textTheme),
          const SizedBox(height: 12),
          ...step.toolsNeeded.map((tool) => _buildInfoCard(tool, '', customColors, textTheme)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, AppCustomColors customColors, TextTheme textTheme) {
    return Row(
      children: [
        Icon(icon, color: customColors.darkSage, size: 18),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: customColors.darkSage,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String trailing, AppCustomColors customColors, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(trailing, style: textTheme.bodySmall?.copyWith(color: customColors.slateGrey)),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter(AppCustomColors customColors, TextTheme textTheme, AppLocalizations l10n) {
    final isLast = _currentStepGlobalIndex == _allSteps.length - 1;
    final isFirst = _currentStepGlobalIndex == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          if (!isFirst)
            IconButton.filled(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: customColors.chartTabBackground,
                foregroundColor: customColors.darkSage,
                minimumSize: const Size(56, 56),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                if (isLast) {
                  context.pop();
                } else {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: customColors.darkSage,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isLast ? l10n.wizardFinish : l10n.wizardNext,
                style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
