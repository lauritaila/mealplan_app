import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/delete_account_provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Future<void> _showDeleteAccountModal(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.confirmDeleteWithEmail(email)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.emailPlaceholder,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final confirmationEmail = controller.text.trim();
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();

              final startedAt = DateTime.now();
              AppError? appError;

              if (!context.mounted) return;
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (_) {
                  return AlertDialog(
                    content: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Expanded(child: Text(l10n.profileFarewell)),
                      ],
                    ),
                  );
                },
              );

              try {
                await ref
                    .read(deleteAccountProvider.notifier)
                    .deleteAccount(confirmationEmail);
              } on AppError catch (e) {
                appError = e;
              }

              final elapsed = DateTime.now().difference(startedAt);
              if (elapsed < const Duration(seconds: 5)) {
                await Future.delayed(const Duration(seconds: 5) - elapsed);
              }

              if (!context.mounted) return;
              final rootNavigator = Navigator.of(context, rootNavigator: true);
              if (rootNavigator.canPop()) {
                rootNavigator.pop();
              }

              if (appError != null) {
                final errorText = localizeAppError(l10n, appError);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorText)));
                return;
              }

              if (!context.mounted) return;
              await ref.read(authProvider.notifier).logOut();
            },
            child: Text(l10n.deleteAccount),
          ),
        ],
      );
    },
  );

  controller.dispose();
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    String displayName = l10n.profileGuestName;
    String email = '-';
    String planName = l10n.profileSubscriptionFree;

    if (authState is AuthenticatedAuthState) {
      displayName = authState.user.name?.trim().isNotEmpty == true
          ? authState.user.name!.trim()
          : l10n.profileGuestName;
      email = authState.user.email;
      planName = authState.user.planName ?? l10n.profileSubscriptionFree;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con información del usuario y plan
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(planName),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.settingsTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(l10n.profilePreferencesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/preferences');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l10n.profileChangeEmailLabel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/change-email');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.profileLanguageTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/language');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(l10n.profilePaymentsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/view-payments');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.subscriptions_outlined),
                  title: Text(l10n.profileSubscriptionTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/profile/subscription');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(l10n.profileNotificationsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.profileTermsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).logOut(),
              child: Text(l10n.logout),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authState is AuthenticatedAuthState
                  ? () => _showDeleteAccountModal(context, ref, email)
                  : null,
              child: Text(l10n.deleteAccount),
            ),
          ),
        ],
      ),
    );
  }
}
