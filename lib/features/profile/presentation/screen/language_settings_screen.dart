import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/language_settings_provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    String? persistedCode;
    if (authState is AuthenticatedAuthState) {
      persistedCode = authState.user.configurations?['language'] as String?;
    }
    final currentCode =
      persistedCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileLanguageTitle)),
      body: ListView(
        children: [
          RadioMenuButton<String>(
            value: 'en',
            groupValue: currentCode,
            onChanged: (value) async {
              if (value == null) return;
              try {
                profileNotifier.setLanguageCode(value);
                await ref
                    .read(languageSettingsProvider.notifier)
                    .updateLanguage(value);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } on AppError catch (e) {
                if (!context.mounted) return;
                final errorText = localizeAppError(l10n, e);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorText)));
              }
            },
            child: Text(l10n.profileLanguageEnglish),
          ),
          RadioMenuButton<String>(
            value: 'es',
            groupValue: currentCode,
            onChanged: (value) async {
              if (value == null) return;
              try {
                profileNotifier.setLanguageCode(value);
                await ref
                    .read(languageSettingsProvider.notifier)
                    .updateLanguage(value);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } on AppError catch (e) {
                if (!context.mounted) return;
                final errorText = localizeAppError(l10n, e);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorText)));
              }
            },
            child: Text(l10n.profileLanguageSpanish),
          ),
        ],
      ),
    );
  }
}
