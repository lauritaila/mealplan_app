import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class HomePremiumBanner extends StatelessWidget {
  const HomePremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: customColors.chartTabBackground?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: customColors.chartTabBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium, 
              color: customColors.darkSage, 
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.goPremiumUnlockMorePlans,
              style: textTheme.bodySmall?.copyWith(
                color: customColors.textDarkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go(
              '/premium',
              extra: {
                'title': l10n.goPremiumTitle,
                'message': l10n.freePlanLimitedGenerations,
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors.darkSage,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(l10n.premiumLearnMore, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
