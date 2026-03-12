import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/presentation/providers/legal_provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class LegalScreen extends ConsumerWidget {
  final String name; // 'privacy_policy' or 'terms_and_conditions'

  const LegalScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final legalContentAsync = ref.watch(getLegalContentProvider(configName: name, language: language));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Determinar el título basado en el nombre de la configuración si no ha cargado
    final fallbackTitle = name == 'privacy_policy' ? l10n.profilePrivacyTitle : l10n.profileTermsTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          legalContentAsync.when(
            data: (content) => content?.title ?? fallbackTitle,
            loading: () => fallbackTitle,
            error: (_, __) => fallbackTitle,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: legalContentAsync.when(
        data: (content) {
          if (content == null) {
            return Center(child: Text(l10n.genericError));
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ...content.sections.map((section) => _LegalSectionWidget(
                      header: section.header,
                      content: section.content,
                      index: content.sections.indexOf(section) + 1,
                    )),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
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
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
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
