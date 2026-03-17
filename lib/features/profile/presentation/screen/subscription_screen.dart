import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/domain.dart';
import 'package:meal_plan_app/features/meal_plan/presentation/providers/provider.dart';
import 'package:meal_plan_app/features/meal_plan/domain/entities/entities.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/shared/presentation/widgets/promo_code_bottom_sheet.dart';

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
    bool isFreePlan = true;

    if (authState is AuthenticatedAuthState) {
      planName = authState.user.planName ?? l10n.profileSubscriptionFree;
      permissionsDescription = authState.user.permissions?.description;
      isFreePlan = authState.user.planName == null || authState.user.planName!.trim().toLowerCase() == 'free';
    }

    final statusAsync = ref.watch(canGenerateMealPlanProvider);
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
                   statusAsync.when(
                    data: (canGen) => _SubscriptionUsageSection(canGen: canGen, isFreePlan: isFreePlan),
                    loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
                    error: (error, stack) => Center(
                      child: Column(
                        children: [
                          Text(
                            l10n.genericError,
                            style: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => ref.refresh(canGenerateMealPlanProvider),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
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

class _SubscriptionUsageSection extends ConsumerWidget {
  final CanGenerateMealPlanResponse canGen;
  final bool isFreePlan;

  const _SubscriptionUsageSection({
    required this.canGen,
    required this.isFreePlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UsageItem(
          label: l10n.mealPlansLabel,
          remaining: canGen.mealPlanGenerateRemaining,
          limit: canGen.mealPlanGenerateLimit,
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 20),
        _UsageItem(
          label: l10n.substitutesLabel,
          remaining: canGen.substituteRemaining,
          limit: canGen.substituteLimit,
          icon: Icons.rebase_edit,
        ),
        const SizedBox(height: 20),
        _UsageItem(
          label: l10n.regenerationsLabel,
          remaining: canGen.regenerateRecipeRemaining,
          limit: canGen.regenerateRecipeLimit,
          icon: Icons.refresh_rounded,
        ),
        const SizedBox(height: 20),
        _UsageItem(
          label: l10n.cookingAssistantLabel,
          remaining: canGen.recipeAssistantRemaining,
          limit: canGen.recipeAssistantLimit,
          icon: Icons.restaurant_menu_rounded,
        ),
        if (isFreePlan) ...[
          const SizedBox(height: 32),
          _UpgradeUpsellCard(),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                PromoCodeBottomSheet.show(context, planId: 'pro'); // Default to pro for now
              },
              child: Text(
                l10n.havePromoCode,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).extension<AppCustomColors>()?.darkSage,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UsageItem extends StatelessWidget {
  final String label;
  final int remaining;
  final int limit;
  final IconData icon;

  const _UsageItem({
    required this.label,
    required this.remaining,
    required this.limit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    final double progress = limit > 0 ? ((limit - remaining) / limit).clamp(0.0, 1.0) : 0.0;
    final bool isExhausted = limit > 0 && remaining <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: isExhausted ? Colors.red : customColors.darkSage),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: customColors.textDarkBlue,
                ),
              ),
            ),
            Text(
              '$remaining / $limit',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: isExhausted ? Colors.red : customColors.darkSage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: customColors.chartTabBackground,
            valueColor: AlwaysStoppedAnimation<Color>(
              isExhausted ? Colors.red : (customColors.darkSage ?? Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpgradeUpsellCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customColors.darkSage ?? Colors.green,
            (customColors.darkSage ?? Colors.green).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.goPremiumTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.goPremiumUnlockMorePlans,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/premium', extra: {
                'title': l10n.goPremiumTitle,
                'message': l10n.freePlanLimitedGenerations,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: customColors.darkSage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                l10n.premiumLearnMore,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
