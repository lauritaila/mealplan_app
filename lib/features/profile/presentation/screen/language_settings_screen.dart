import 'package:meal_plan_app/features/shared/shared.dart';
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
    final theme = Theme.of(context);
    final state = ref.watch(languageSettingsProvider);
    final notifier = ref.read(languageSettingsProvider.notifier);
    final primaryGreen = theme.colorScheme.primary;
    final darkText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurfaceVariant;

    final languages = [
      {'code': 'en', 'name': 'English', 'sub': 'United States'},
      {'code': 'es', 'name': 'Spanish', 'sub': 'Español'},
      // {'code': 'de', 'name': 'German', 'sub': 'Deutsch'}, // Keep it for future if needed, or follow image
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.profileLanguageTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Choose your preferred language for the application interface.',
              style: TextStyle(
                fontSize: 15,
                color: secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = state.selectedCode == lang['code'];
                  return GestureDetector(
                    onTap: () => notifier.select(lang['code']!),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? primaryGreen : theme.colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lang['sub']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Custom Radio
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? primaryGreen : theme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                        child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSaving || state.selectedCode == state.persistedCode
                      ? null
                      : () async {
                          await notifier.confirm();
                          if (!context.mounted) return;
                          final updatedState = ref.read(languageSettingsProvider);
                          if (updatedState.error == null &&
                              updatedState.selectedCode == updatedState.persistedCode) {
                            Navigator.of(context).pop();
                          } else if (updatedState.error != null) {
                            final errorText = localizeAppError(l10n, updatedState.error!);
                            CustomSnackbar.showInfo(context, errorText);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          l10n.profileSavePreferences, // Use "Guardar" as per image
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
