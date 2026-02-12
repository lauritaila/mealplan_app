import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final localeCode = Localizations.localeOf(context).languageCode;

    String planName = l10n.profileSubscriptionFree;
    Map<String, List<String>>? permissionsDescription;

    if (authState is AuthenticatedAuthState) {
      planName = authState.user.planName ?? l10n.profileSubscriptionFree;
      permissionsDescription = authState.user.permissions?.description;
    }

    final includes = _subscriptionIncludes(permissionsDescription, localeCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSubscriptionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileSubscriptionCurrentLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(planName, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  l10n.profileSubscriptionIncludesLabel,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (includes.isEmpty)
                  Text(
                    l10n.profileNoIncludes,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Column(
                    children: includes
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
