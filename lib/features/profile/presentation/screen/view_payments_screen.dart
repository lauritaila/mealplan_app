import 'package:flutter/material.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class ViewPaymentsScreen extends StatelessWidget {
  const ViewPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.profilePaymentsTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: customColors.chartTabBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: customColors.slateGrey?.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.profilePaymentsEmpty,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: customColors.slateGrey,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
