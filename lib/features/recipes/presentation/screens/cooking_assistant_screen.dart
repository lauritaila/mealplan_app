import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/utils/ingredient_substitute_flow.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/cooking_timer_card.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/cooking_info_card.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/cooking_assistant_progress_bar.dart';
import 'package:meal_plan_app/features/recipes/presentation/widgets/cooking_step_instruction_card.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class CookingAssistantScreen extends ConsumerStatefulWidget {
  final int recipeId;

  const CookingAssistantScreen({super.key, required this.recipeId});

  @override
  ConsumerState<CookingAssistantScreen> createState() =>
      _CookingAssistantScreenState();
}

class _CookingAssistantScreenState
    extends ConsumerState<CookingAssistantScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final stepsAsync = ref.watch(cookingAssistantStepsProvider(widget.recipeId));
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: customColors.textDarkBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.cookingAssistantTitle,
          style: textTheme.titleLarge?.copyWith(
            color: customColors.textDarkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: stepsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(cookingAssistantStepsProvider(widget.recipeId)),
        ),
        data: (steps) {
          if (steps.isEmpty) {
            return AppEmptyState(
              title: l10n.noCookingSteps,
              icon: Icons.outdoor_grill_outlined,
            );
          }

          return Column(
            children: [
              CookingAssistantProgressBar(
                currentIndex: _currentIndex,
                totalSteps: steps.length,
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: steps.length,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        CookingStepInstructionCard(instruction: step.instruction),
                        const SizedBox(height: 16),

                        if (step.isTimerNecessary) ...[
                          CookingTimerCard(seconds: step.estimatedTimeSeconds),
                          const SizedBox(height: 24),
                        ],

                        Row(
                          children: [
                            Icon(Icons.list_alt, color: customColors.darkSage, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.neededForThisStep,
                              style: textTheme.titleMedium?.copyWith(
                                color: customColors.textDarkBlue,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        ...step.ingredientsUsed.map((ingredient) => CookingInfoCard(
                          icon: Icons.eco_outlined,
                          title: _formatIngredientLine(
                            quantity: ingredient.quantity,
                            unit: ingredient.unit,
                            name: ingredient.name,
                          ),
                          subtitle: l10n.mainIngredientSubtitle,
                          onTap: () => showIngredientSubstituteFlow(
                            context: context,
                            ref: ref,
                            recipeId: widget.recipeId,
                            ingredient: ingredient,
                            hideNutritionValues: hideNutritionValues,
                            contextHint: step.instruction,
                          ),
                        )),

                        ...step.toolsNeeded.map((tool) => CookingInfoCard(
                          icon: Icons.kitchen_outlined,
                          title: tool,
                          subtitle: l10n.neededToolSubtitle,
                        )),
                        
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),

              _NavigationFooter(
                currentIndex: _currentIndex,
                totalSteps: steps.length,
                onNext: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                onPrevious: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                onFinish: _completeRecipe,
                onReset: () => _pageController.jumpToPage(0),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _completeRecipe() async {
     final l10n = AppLocalizations.of(context);
     final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
     final result = await notifier.bulkDeduct(widget.recipeId, 1);
     
     if (!mounted) return;
     
     if (result != null) {
        CustomSnackbar.showInfo(context, result.missing.isEmpty ? l10n.recipeCompletedSnack : l10n.recipeCompletedMissingSnack(result.missing.length));
     }
     context.pop();
  }

  String _formatIngredientLine({
    required double? quantity,
    required String unit,
    required String name,
  }) {
    final safeName = name.trim();
    final safeUnit = unit.trim();

    String quantityText = '';
    if (quantity != null) {
      quantityText = quantity == quantity.roundToDouble()
          ? quantity.toInt().toString()
          : quantity
              .toStringAsFixed(2)
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '');
    }

    return [
      quantityText,
      if (safeUnit.isNotEmpty) safeUnit,
      safeName,
    ].join(' ');
  }
}

class _NavigationFooter extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onFinish;
  final VoidCallback onReset;

  const _NavigationFooter({
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onFinish,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: currentIndex < totalSteps - 1 ? onNext : onFinish,
              style: FilledButton.styleFrom(
                backgroundColor: customColors.darkSage,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentIndex < totalSteps - 1
                        ? l10n.nextStepAction
                        : l10n.finishRecipeAction,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    currentIndex < totalSteps - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: currentIndex > 0 ? onPrevious : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: Text(l10n.wizardPrevious),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: customColors.chartTabBackground,
                      foregroundColor: customColors.darkSage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.replay, size: 18),
                    label: Text(l10n.resetTimer),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: customColors.chartTabBackground,
                      foregroundColor: customColors.slateGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

