import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

class HomeEmptyPlanWidget extends StatelessWidget {
  const HomeEmptyPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: customColors.chartTabBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 60,
                  color: customColors.slateGrey?.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.edit_calendar, size: 20, color: customColors.darkSage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.homeEmptyPlanTitle,
          style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: customColors.textDarkBlue,
              ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.homeEmptyPlanMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: customColors.slateGrey,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        CustomFilledButton(
          text: l10n.generateNewPlan,
          icon: Icons.auto_awesome,
          onPressed: () => context.push('/meal-plan/new'),
        ),
      ],
    );
  }
}
