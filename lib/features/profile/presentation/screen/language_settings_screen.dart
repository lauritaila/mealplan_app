import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    final currentCode =
        profileState.languageCode ??
        Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileLanguageTitle)),
      body: ListView(
        children: [
          RadioMenuButton<String>(
            value: 'en',
            groupValue: currentCode,
            onChanged: (value) {
              if (value == null) return;
              profileNotifier.setLanguageCode(value);
              Navigator.of(context).pop();
            },
            child: Text(l10n.profileLanguageEnglish),
          ),
          RadioMenuButton<String>(
            value: 'es',
            groupValue: currentCode,
            onChanged: (value) {
              if (value == null) return;
              profileNotifier.setLanguageCode(value);
              Navigator.of(context).pop();
            },
            child: Text(l10n.profileLanguageSpanish),
          ),
        ],
      ),
    );
  }
}
