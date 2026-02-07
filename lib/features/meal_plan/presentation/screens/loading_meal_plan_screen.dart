import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';

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
  List<String> _messages = const [];
  bool _tickerStarted = false;

  int _messageIndex = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _triggerGeneration();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _messages = [
      l10n.loadingMessageCookbook,
      l10n.loadingMessageRecipes,
      l10n.loadingMessageAunts,
      l10n.loadingMessageFridge,
      l10n.loadingMessageKnives,
      l10n.loadingMessageTablespoons,
    ];
    if (_messageIndex >= _messages.length) {
      _messageIndex = 0;
    }
    if (!_tickerStarted) {
      _cycleMessages();
      _tickerStarted = true;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _cycleMessages() {
    if (_messages.isEmpty) return;
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

  bool _isQuotaError(String? message, String? code) {
    if (code == 'MEAL_PLAN_QUOTA_REACHED') return true;
    if (message == null) return false;
    final normalized = message.toLowerCase();
    return normalized.contains('limit of') && normalized.contains('plans');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen<MealPlanGeneratorState>(mealPlanGeneratorProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == MealPlanGeneratorStatus.success &&
          next.generatedPlan != null) {
        context.go('/meal-plan/approve', extra: next.generatedPlan);
      } else if (next.status == MealPlanGeneratorStatus.error) {
        final message = next.errorMessage;
        if (_isQuotaError(message, next.errorCode)) {
          ref.read(mealPlanGeneratorProvider.notifier).reset();
          context.go(
            '/premium',
            extra: {
              'title': l10n.planLimitReachedTitle,
              'message': l10n.planLimitReachedMessage,
            },
          );
          return;
        }

        context.pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                localizeErrorCode(
                  l10n,
                  next.errorCode,
                  fallback: message,
                ),
              ),
            ),
          );
      }
    });

    final state = ref.watch(mealPlanGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.preparingPlanTitle),
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
                  _messages.isEmpty ? '' : _messages[_messageIndex],
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
                    ? localizeErrorCode(
                        l10n,
                        state.errorCode,
                        fallback: state.errorMessage,
                      )
                    : l10n.cookingCombosMessage,
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
                label: Text(l10n.cancelAndGoBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
