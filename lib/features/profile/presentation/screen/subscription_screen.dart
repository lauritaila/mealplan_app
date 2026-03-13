import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

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
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
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
      appBar: AppBar(
        title: Text(
          l10n.profileSubscriptionTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileSubscriptionCurrentLabel.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: customColors.slateGrey?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    planName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: customColors.textDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PlanStatusCard(
                    statusAsync: statusAsync,
                    totalAllowed: totalAllowed,
                    isFreePlan: isFreePlan,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.profileSubscriptionIncludesLabel.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: customColors.slateGrey?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (includes.isEmpty)
                    Text(
                      l10n.profileNoIncludes,
                      style: textTheme.bodyMedium?.copyWith(
                        color: customColors.slateGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ...includes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: customColors.darkSage,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: customColors.textDarkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
  final bool isFreePlan;

  const _PlanStatusCard({
    required this.statusAsync,
    required this.totalAllowed,
    required this.isFreePlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return statusAsync.when(
      loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.unableToLoadPlanStatus(l10n.genericError),
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.plansLeftThisWeek(remaining, total),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: customColors.textDarkBlue,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.darkSage,
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
                backgroundColor: customColors.chartTabBackground,
                valueColor: AlwaysStoppedAnimation<Color>(customColors.darkSage!),
              ),
            ),
            if (!status.canGenerate && status.reason != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.reason!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isFreePlan) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: customColors.chartTabBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.goPremiumUnlockMorePlans,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: customColors.textDarkBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => context.go(
                          '/premium',
                          extra: {
                            'title': l10n.goPremiumTitle,
                            'message': l10n.freePlanLimitedGenerations,
                          },
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: customColors.darkSage,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          l10n.goPremiumTitle,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
