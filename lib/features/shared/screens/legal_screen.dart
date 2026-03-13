import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/presentation/providers/legal_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';

class LegalScreen extends ConsumerWidget {
  final String name; // 'privacy_policy' or 'terms_and_conditions'

  const LegalScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final legalContentAsync = ref.watch(getLegalContentProvider(configName: name, language: language));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;

    final fallbackTitle = name == 'privacy_policy' ? l10n.profilePrivacyTitle : l10n.profileTermsTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          legalContentAsync.when(
            data: (content) => content?.title ?? fallbackTitle,
            loading: () => fallbackTitle,
            error: (_, _) => fallbackTitle,
          ),
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
      ),
      body: legalContentAsync.when(
        data: (content) {
          if (content == null) {
            return Center(
              child: Text(
                l10n.genericError,
                style: textTheme.bodyLarge?.copyWith(color: customColors.slateGrey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.lastUpdated.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l10n.lastUpdatedLabel}: ${content.lastUpdated}',
                      style: textTheme.labelSmall?.copyWith(
                        color: customColors.slateGrey?.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                ...content.sections.asMap().entries.map((entry) => _LegalSectionWidget(
                      header: entry.value.header,
                      content: entry.value.content,
                      index: entry.key + 1,
                    )),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: customColors.darkSage)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              error.toString(),
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSectionWidget extends StatelessWidget {
  final String header;
  final String content;
  final int index;

  const _LegalSectionWidget({
    required this.header,
    required this.content,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: customColors.darkSage,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: customColors.slateGrey,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
