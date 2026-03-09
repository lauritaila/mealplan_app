import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  List<String> _subscriptionIncludes(
    Map<String, List<String>>? description,
    String languageCode,
  ) {
    if (description == null) return [];
    final items = description[languageCode] ?? description['en'] ?? [];
    return items.where((item) => item.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final localeCode = Localizations.localeOf(context).languageCode;

    String planName = l10n.profileSubscriptionFree;
    Map<String, List<String>>? permissionsDescription;
    int? totalAllowed;
    bool isFreePlan = true;

    if (authState is AuthenticatedAuthState) {
      planName = authState.user.planName ?? l10n.profileSubscriptionFree;
      permissionsDescription = authState.user.permissions?.description;
      totalAllowed = authState.user.permissions?.permissions.mealPlanGenerate;
      isFreePlan = authState.user.planName == null || authState.user.planName!.trim().toLowerCase() == 'free';
    }

    final statusAsync = ref.watch(mealPlanGenerationStatusProvider);
    final includes = _subscriptionIncludes(permissionsDescription, localeCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSubscriptionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileSubscriptionCurrentLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(planName, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                _PlanStatusCard(
                  statusAsync: statusAsync,
                  totalAllowed: totalAllowed,
                  isFreePlan: isFreePlan,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileSubscriptionIncludesLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (includes.isEmpty)
                  Text(
                    l10n.profileNoIncludes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Column(
                    children: includes
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanStatusCard extends StatelessWidget {
  final AsyncValue statusAsync;
  final int? totalAllowed;
  final bool isFreePlan;

  const _PlanStatusCard({
    required this.statusAsync,
    required this.totalAllowed,
    required this.isFreePlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // No extra Card since it's already inside a Card in SubscriptionScreen
    return statusAsync.when(
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
            if (isFreePlan) ...[
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
    );
  }
}
