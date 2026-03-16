import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/shared/providers/subscription_plans_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class PremiumScreen extends ConsumerWidget {
  final String title;
  final String message;

  const PremiumScreen({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>() ?? const AppCustomColors();
    final locale = Localizations.localeOf(context).languageCode;
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final authState = ref.watch(authProvider);

    final currentPlanName = authState is AuthenticatedAuthState
        ? (authState.user.planName?.toLowerCase() ?? 'free')
        : 'free';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Gradient hero header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    customColors.darkSage ?? const Color(0xFF5C7A5C),
                    (customColors.darkSage ?? const Color(0xFF5C7A5C))
                        .withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go('/home'),
                            tooltip: l10n.close,
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title.isNotEmpty ? title : l10n.goPremiumTitle,
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message.isNotEmpty
                            ? message
                            : l10n.freePlanLimitedGenerations,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Plans section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.choosePlanLabel.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: customColors.slateGrey?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          plansAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: customColors.darkSage),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    l10n.genericError,
                    style: textTheme.bodyMedium?.copyWith(
                      color: customColors.slateGrey,
                    ),
                  ),
                ),
              ),
            ),
            data: (plans) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final plan = plans[index];
                  final isCurrent = plan.name.toLowerCase() == currentPlanName;
                  final isPro = plan.name.toLowerCase().contains('pro');
                  final isPremium =
                      plan.name.toLowerCase().contains('premium');
                  final isFeatured = isPro || isPremium;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: _PlanCard(
                      plan: plan,
                      locale: locale,
                      isCurrent: isCurrent,
                      isFeatured: isFeatured,
                      customColors: customColors,
                      textTheme: textTheme,
                    ),
                  );
                },
                childCount: plans.length,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String locale;
  final bool isCurrent;
  final bool isFeatured;
  final AppCustomColors customColors;
  final TextTheme textTheme;

  const _PlanCard({
    required this.plan,
    required this.locale,
    required this.isCurrent,
    required this.isFeatured,
    required this.customColors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = plan.descriptionList(locale);

    return Container(
      decoration: BoxDecoration(
        color: isFeatured ? customColors.darkSage : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: isCurrent
            ? Border.all(
                color: customColors.darkSage ?? Colors.green,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isFeatured ? 0.12 : 0.04),
            blurRadius: isFeatured ? 24 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isFeatured
                                  ? Colors.white
                                  : customColors.textDarkBlue,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.currentPlanBadge,
                                style: textTheme.labelSmall?.copyWith(
                                  color: isFeatured
                                      ? Colors.white
                                      : customColors.darkSage,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          if (isFeatured && !isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                l10n.recommendedBadge,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.price == 0
                                ? l10n.freePriceLabel
                                : '\$${plan.price.toStringAsFixed(2)}',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isFeatured
                                  ? Colors.white
                                  : customColors.textDarkBlue,
                            ),
                          ),
                          if (plan.price > 0) ...[
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '/ ${l10n.perMonthLabel}',
                                style: textTheme.labelMedium?.copyWith(
                                  color: isFeatured
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : customColors.slateGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (features.isNotEmpty) ...[
              const SizedBox(height: 20),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: isFeatured
                            ? Colors.white.withValues(alpha: 0.9)
                            : customColors.darkSage,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature,
                          style: textTheme.bodySmall?.copyWith(
                            color: isFeatured
                                ? Colors.white.withValues(alpha: 0.9)
                                : customColors.textDarkBlue,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!isCurrent) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    // Contact/payment flow — navigate to web or show info
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.contactSalesMessage),
                        backgroundColor: customColors.darkSage,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isFeatured
                        ? Colors.white
                        : customColors.darkSage,
                    foregroundColor: isFeatured
                        ? customColors.darkSage
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    plan.price == 0
                        ? l10n.stayFreeLabel
                        : l10n.upgradeToLabel(plan.name),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
