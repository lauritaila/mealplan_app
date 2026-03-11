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
      backgroundColor: const Color(0xFFF8F9FA), // Light background like in mockup
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A614A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.cookingAssistantTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF2D3E2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF4A614A)),
            onPressed: () {},
          ),
        ],
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

          final progress = (_currentIndex + 1) / steps.length;
          final percentage = (progress * 100).toInt();

          return Column(
            children: [
              // Progress Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cookingProgress,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF8A9A8A),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: l10n.stepOfTotal(_currentIndex + 1, steps.length),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF4A614A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          l10n.percentCompleted(percentage),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8A9A8A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE8EDE8),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A614A)),
                      ),
                    ),
                  ],
                ),
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
                        // Instruction Card
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  step.instruction.split('\n').first.trim().replaceFirst(RegExp(r'^\d+[\.\)\s]+'), ''),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF1B261B),
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                                if (step.instruction.contains('\n')) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    step.instruction.substring(step.instruction.indexOf('\n') + 1).trim(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5A6B5A),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Timer Card
                        if (step.isTimerNecessary) ...[
                          _TimerCard(seconds: step.estimatedTimeSeconds),
                          const SizedBox(height: 24),
                        ],

                        // Ingredients and Tools Section Header
                        Row(
                          children: [
                            const Icon(Icons.list_alt, color: Color(0xFF4A614A), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.neededForThisStep,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF1B261B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Ingredients
                        ...step.ingredientsUsed.map((ingredient) => _InfoCard(
                          icon: Icons.eco_outlined,
                          title: _formatIngredientLine(
                            quantity: ingredient.quantity,
                            unit: ingredient.unit,
                            name: ingredient.name,
                          ),
                          subtitle: l10n.mainIngredientSubtitle, // Could be dynamic if available
                          onTap: () => showIngredientSubstituteFlow(
                            context: context,
                            ref: ref,
                            recipeId: widget.recipeId,
                            ingredient: ingredient,
                            hideNutritionValues: hideNutritionValues,
                            contextHint: step.instruction,
                          ),
                        )),

                        // Tools
                        ...step.toolsNeeded.map((tool) => _InfoCard(
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

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _currentIndex < steps.length - 1
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : _completeRecipe,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4A614A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex < steps.length - 1
                                  ? l10n.nextStepAction
                                  : l10n.finishRecipeAction,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentIndex < steps.length - 1
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
                              onPressed: _currentIndex > 0
                                  ? () => _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      )
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              label: Text(l10n.wizardPrevious),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor: const Color(0xFFE8EDE8),
                                foregroundColor: const Color(0xFF4A614A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                              onPressed: () {
                                _pageController.jumpToPage(0);
                              },
                              icon: const Icon(Icons.replay, size: 18),
                              label: Text(l10n.resetTimer),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                backgroundColor: const Color(0xFFEDF2F7),
                                foregroundColor: const Color(0xFF4A5568),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
     final notifier = ref.read(mealPlanEntryActionsProvider.notifier);
     final result = await notifier.bulkDeduct(widget.recipeId, 1);
     if (!context.mounted) return;
     if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(result.missing.isEmpty ? l10n.recipeCompletedSnack : l10n.recipeCompletedMissingSnack(result.missing.length))),
        );
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

class _TimerCard extends StatefulWidget {
  final int seconds;

  const _TimerCard({required this.seconds});

  @override
  State<_TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<_TimerCard> {
  Timer? _timer;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
  }

  @override
  void didUpdateWidget(covariant _TimerCard oldWidget) {
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
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr : $secStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Card(
      elevation: 0,
      color: const Color(0xFFEFF3EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              l10n.timerLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF4A614A),
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF2D3E2D), size: 32),
                const SizedBox(width: 12),
                Text(
                  _formatTime(_remaining),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: const Color(0xFF1A201A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? l10n.pauseTimer : l10n.startTimer),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A614A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF4A5568),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDE8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4A614A), size: 24),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B261B),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8A9A8A),
            ),
          ),
          trailing: onTap != null 
            ? const Icon(Icons.swap_horiz, color: Color(0xFF8A9A8A), size: 20)
            : null,
        ),
      ),
    );
  }
}

