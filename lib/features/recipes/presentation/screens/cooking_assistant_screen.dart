import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/recipes/domain/domain.dart';
import 'package:meal_plan_app/features/recipes/presentation/providers/providers.dart';
import 'package:meal_plan_app/features/recipes/presentation/utils/ingredient_substitute_flow.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
    final stepsAsync = ref.watch(cookingAssistantStepsProvider(widget.recipeId));
    final authState = ref.watch(authProvider);
    final hideNutritionValues =
        authState is AuthenticatedAuthState &&
        authState.user.configurations?['hideNutritionValues'] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cookingAssistantTitle),
      ),
      body: stepsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorOccurred(error.toString())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  cookingAssistantStepsProvider(widget.recipeId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (steps) {
          if (steps.isEmpty) {
            return Center(child: Text(l10n.noCookingSteps));
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cookingAssistantDisclaimer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.stepOf(_currentIndex + 1, steps.length),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return _AssistantStepCard(
                      step: step,
                      backgroundColor: _pastelColor(index),
                      onSubstituteTap: (ingredient) {
                        return showIngredientSubstituteFlow(
                          context: context,
                          ref: ref,
                          recipeId: widget.recipeId,
                          ingredient: ingredient,
                          hideNutritionValues: hideNutritionValues,
                          contextHint: step.instruction,
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentIndex > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(l10n.back),
                      ),
                    const Spacer(),
                    if (_currentIndex < steps.length - 1)
                      FilledButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(l10n.next),
                      )
                    else
                      FilledButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: _completeRecipe,
                        label: Text(l10n.complete_recipe),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _completeRecipe() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
      final result = await notifier.bulkDeduct(widget.recipeId, 1);

      if (!mounted) return;

      if (result != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.missing.isEmpty
                  ? l10n.allIngredientsDeducted(result.deducted.length)
                  : l10n.someIngredientsMissing(result.missing.length),
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bulkDeductUnknownError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.genericError)),
      );
    } finally {
      if (mounted) {
        context.pop();
      }
    }
  }

  Color _pastelColor(int index) {
    final palette = [
      Colors.pink.shade50,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.amber.shade50,
      Colors.purple.shade50,
      Colors.teal.shade50,
    ];
    return palette[index % palette.length];
  }
}

class _AssistantStepCard extends StatelessWidget {
  final CookingAssistantStep step;
  final Color backgroundColor;
  final Future<void> Function(RecipeIngredient ingredient) onSubstituteTap;

  const _AssistantStepCard({
    required this.step,
    required this.backgroundColor,
    required this.onSubstituteTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.cookingAssistantStepLabel(step.stepNumber),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.instruction,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StepTimer(seconds: step.estimatedTimeSeconds),
          const SizedBox(height: 16),
          Text(
            l10n.cookingAssistantIngredientsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (step.ingredientsUsed.isEmpty)
            Text(l10n.noIngredients, style: theme.textTheme.bodyLarge)
          else
            ...step.ingredientsUsed.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatIngredientLine(
                          quantity: ingredient.quantity,
                          unit: ingredient.unit,
                          name: ingredient.name,
                        ),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      tooltip: l10n.ingredientSubstitutesTooltip,
                      onPressed: () {
                        onSubstituteTap(ingredient);
                      },
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          Text(
            l10n.cookingAssistantToolsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (step.toolsNeeded.isEmpty)
            Text(l10n.noToolsNeeded, style: theme.textTheme.bodyLarge)
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: step.toolsNeeded.map((tool) {
                return Chip(
                  label: Text(tool),
                  backgroundColor: theme.colorScheme.surface,
                );
              }).toList(),
            ),
        ],
      ),
    );
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
      safeUnit,
      safeName,
    ].where((part) => part.isNotEmpty).join(' ');
  }
}

class StepTimer extends StatefulWidget {
  final int seconds;

  const StepTimer({super.key, required this.seconds});

  @override
  State<StepTimer> createState() => _StepTimerState();
}

class _StepTimerState extends State<StepTimer> {
  Timer? _timer;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  @override
  void didUpdateWidget(covariant StepTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seconds != widget.seconds) {
      _remaining = widget.seconds;
      _timer?.cancel();
      _running = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_remaining <= 0) return;
    if (_running) {
      _timer?.cancel();
      setState(() {
        _running = false;
      });
      return;
    }

    setState(() {
      _running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      } else {
        setState(() {
          _remaining -= 1;
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remaining = widget.seconds;
      _running = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final padded = seconds.toString().padLeft(2, '0');
    return '$minutes:$padded';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (widget.seconds <= 0) {
      return Text(
        l10n.noTimerAvailable,
        style: theme.textTheme.bodyMedium,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.estimatedTimeLabel(_formatTime(_remaining)),
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: _toggleTimer,
              child: Text(
                _running ? l10n.pauseTimer : l10n.startTimer,
              ),
            ),
            TextButton(
              onPressed: _resetTimer,
              child: Text(l10n.resetTimer),
            ),
          ],
        ),
      ),
    );
  }
}
