import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/language_settings_provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(languageSettingsProvider);
    final notifier = ref.read(languageSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileLanguageTitle)),
      body: Column(
        children: [
          RadioGroup<String>(
            groupValue: state.selectedCode,
            onChanged: (value) {
              if (value == null) return;
              notifier.select(value);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'en',
                  title: Text(l10n.profileLanguageEnglish),
                ),
                RadioListTile<String>(
                  value: 'es',
                  title: Text(l10n.profileLanguageSpanish),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                state.isSaving || state.selectedCode == state.persistedCode
                ? null
                : () async {
                    await notifier.confirm();
                    if (!context.mounted) return;
                    final updatedState = ref.read(languageSettingsProvider);
                    if (updatedState.error == null &&
                        updatedState.selectedCode ==
                            updatedState.persistedCode) {
                      Navigator.of(context).pop();
                    } else if (updatedState.error != null) {
                      final errorText = localizeAppError(
                        l10n,
                        updatedState.error!,
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(errorText)));
                    }
                  },
            child: state.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.continueLabel),
          ),
        ],
      ),
    );
  }
}
