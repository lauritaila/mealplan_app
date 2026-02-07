import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final statusAsync = ref.watch(mealPlanGenerationStatusProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authState is AuthenticatedAuthState) ...[
              _PlanStatusCard(
                statusAsync: statusAsync,
                totalAllowed:
                    authState.user.permissions?.permissions.mealPlanGenerate,
                planName: authState.user.planName ?? 'Free',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).logOut(),
                child: Text(l10n.logout),
              ),
            ),
          ],
        ),
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
              // Text(
              //   'Plan: $planName',
              //   style: Theme.of(context).textTheme.titleMedium,
              // ),
              // const SizedBox(height: 8),
              Text(
                l10n.unableToLoadPlanStatus(error.toString()),
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
                // Text(
                //   'Plan: $planName',
                //   style: Theme.of(context).textTheme.titleMedium,
                // ),
                // const SizedBox(height: 8),
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
