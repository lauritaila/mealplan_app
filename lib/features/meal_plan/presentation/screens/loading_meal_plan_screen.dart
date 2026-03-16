import 'package:meal_plan_app/features/shared/shared.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class LoadingMealPlanScreen extends ConsumerStatefulWidget {
  final String description;
  final int numberOfDays;
  final int quantityOfPeople;
  final List<String> mealTypes;
  final bool usePantry;
  final String? startDate;

  const LoadingMealPlanScreen({
    super.key,
    required this.description,
    required this.numberOfDays,
    required this.quantityOfPeople,
    required this.mealTypes,
    required this.usePantry,
    this.startDate,
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
            usePantry: widget.usePantry,
            startDate: widget.startDate,
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
        CustomSnackbar.showInfo(context, 
                localizeErrorCode(l10n, next.errorCode, fallback: message),
              );
      }
    });

    final state = ref.watch(mealPlanGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.preparingPlanTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).extension<AppCustomColors>()?.textDarkBlue,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).extension<AppCustomColors>()?.textDarkBlue,
          ),
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
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: Theme.of(context).extension<AppCustomColors>()?.darkSage,
                  backgroundColor: Theme.of(context).extension<AppCustomColors>()?.chartTabBackground,
                ),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).extension<AppCustomColors>()?.textDarkBlue,
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).extension<AppCustomColors>()?.slateGrey,
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  ref.read(mealPlanGeneratorProvider.notifier).reset();
                  context.pop();
                },
                icon: const Icon(Icons.close, size: 20),
                label: Text(
                  l10n.cancelAndGoBack.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).extension<AppCustomColors>()?.slateGrey,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<AppCustomColors>()?.chartTabBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).extension<AppCustomColors>()?.darkSage!.withValues(alpha: 0.1) ?? Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).extension<AppCustomColors>()?.darkSage,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.medicalDisclaimer,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).extension<AppCustomColors>()?.slateGrey,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
