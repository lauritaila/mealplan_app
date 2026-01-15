import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';

class LoadingMealPlanScreen extends ConsumerStatefulWidget {
  final String description;
  final int numberOfDays;
  final int quantityOfPeople;
  final List<String> mealTypes;

  const LoadingMealPlanScreen({
    super.key,
    required this.description,
    required this.numberOfDays,
    required this.quantityOfPeople,
    required this.mealTypes,
  });

  @override
  ConsumerState<LoadingMealPlanScreen> createState() =>
      _LoadingMealPlanScreenState();
}

class _LoadingMealPlanScreenState extends ConsumerState<LoadingMealPlanScreen> {
  static const _messages = [
    "Checking grandma's cookbook...",
    "Dusting off the old recipes...",
    "Asking the aunts for their secrets...",
    "Peeking into the fridge...",
    "Sharpening imaginary knives...",
    "Measuring tablespoons by eye...",
  ];

  int _messageIndex = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _cycleMessages();
    _triggerGeneration();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _cycleMessages() {
    _ticker = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });
  }

  void _triggerGeneration() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(mealPlanGeneratorProvider.notifier)
          .generatePlan(
            description: widget.description,
            numberOfDays: widget.numberOfDays,
            quantityOfPeople: widget.quantityOfPeople,
            mealTypes: widget.mealTypes,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MealPlanGeneratorState>(mealPlanGeneratorProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == MealPlanGeneratorStatus.success &&
          next.generatedPlan != null) {
        context.go('/meal-plan/approve', extra: next.generatedPlan);
      } else if (next.status == MealPlanGeneratorStatus.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'No se pudo generar el plan.'),
            ),
          );
      }
    });

    final state = ref.watch(mealPlanGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparando tu plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(mealPlanGeneratorProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.status == MealPlanGeneratorStatus.error
                    ? (state.errorMessage ??
                          'Could not generate the plan. Please try again.')
                    : 'Cooking up tasty, healthy combos for you...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  ref.read(mealPlanGeneratorProvider.notifier).reset();
                  context.pop();
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel and go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
