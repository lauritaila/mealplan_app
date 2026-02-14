import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/home/presentation/providers/home_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewStateProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(homeShowGraceWelcomeProvider, (previous, next) {
      if (next == true && previous != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref.read(authProvider.notifier).consumeGraceWelcome();
          showDialog<void>(
            context: context,
            builder: (_) => const _GraceWelcomeDialog(),
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (homeState.isAuthenticated && homeState.statusAsync != null) ...[
              _PlanStatusCard(
                statusAsync: homeState.statusAsync!,
                totalAllowed: homeState.totalAllowed,
                planName: homeState.planName ?? l10n.profileSubscriptionFree,
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/meal-plan/new'),
                child: Text(l10n.generateNewPlan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraceWelcomeDialog extends StatefulWidget {
  const _GraceWelcomeDialog();

  @override
  State<_GraceWelcomeDialog> createState() => _GraceWelcomeDialogState();
}

class _GraceWelcomeDialogState extends State<_GraceWelcomeDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).graceWelcomeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).graceWelcomeMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).continueLabel),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.04,
            numberOfParticles: 12,
            gravity: 0.2,
            maxBlastForce: 12,
            minBlastForce: 6,
          ),
        ],
      ),
    );
  }
}

class _PlanStatusCard extends StatelessWidget {
  final AsyncValue statusAsync;
  final int? totalAllowed;
  final String planName;

  const _PlanStatusCard({
    required this.statusAsync,
    required this.totalAllowed,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = planName.toLowerCase() == 'free';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.unableToLoadPlanStatus(l10n.genericError),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          data: (status) {
            final total = (totalAllowed ?? status.remaining).clamp(0, 9999);
            final safeTotal = total == 0 ? 1 : total;
            final remaining = status.remaining.clamp(0, safeTotal);
            final progress = (safeTotal - remaining) / safeTotal;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.plansLeftThisWeek(remaining, total),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                if (!status.canGenerate && status.reason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    status.reason!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (isFree) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.goPremiumUnlockMorePlans,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () => context.go(
                        '/premium',
                        extra: {
                          'title': l10n.goPremiumTitle,
                          'message': l10n.freePlanLimitedGenerations,
                        },
                      ),
                      child: Text(l10n.goPremiumTitle),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
