import 'package:meal_plan_app/features/shared/shared.dart';
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
  final theme = Theme.of(context);
  final primaryGreen = theme.colorScheme.primary;
  final darkText = theme.colorScheme.onSurface;
  final secondaryText = theme.colorScheme.onSurfaceVariant;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.deleteAccount,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.confirmDeleteWithEmail(email),
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryText, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@ejemplo.com',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final confirmationEmail = controller.text.trim();
                    if (!dialogContext.mounted) return;

                    final normalizedInput = confirmationEmail.toLowerCase();
                    final normalizedAccount = email.trim().toLowerCase();

                    if (normalizedInput.isEmpty || normalizedInput != normalizedAccount) {
                      final errorText = normalizedInput.isEmpty
                          ? l10n.errorFieldRequired
                          : l10n.errorEmailConfirmationMismatch;
                      CustomSnackbar.showInfo(context, errorText);
                      return;
                    }

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
                      await ref.read(deleteAccountProvider.notifier).deleteAccount(email);
                    } catch (e) {
                      if (e is AppError) {
                        appError = e;
                      } else {
                        appError = NetworkAppError(
                          'Unexpected error deleting account. Please try again.',
                          code: 'UNEXPECTED_DELETE_ACCOUNT_ERROR',
                        );
                      }
                    }

                    final elapsed = DateTime.now().difference(startedAt);
                    if (elapsed < const Duration(seconds: 5)) {
                      await Future.delayed(const Duration(seconds: 5) - elapsed);
                    }

                    if (!context.mounted) return;
                    final rootNavigator = Navigator.of(context, rootNavigator: true);
                    if (rootNavigator.canPop()) rootNavigator.pop();

                    if (appError != null) {
                      final errorText = localizeAppError(l10n, appError);
                      CustomSnackbar.showInfo(context, errorText);
                      return;
                    }

                    if (!context.mounted) return;
                    await ref.read(authProvider.notifier).logOut();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.deleteAccount,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: secondaryText, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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
      planName = authState.user.planName ?? l10n.profilePlanFreeBadge;
    } else {
      planName = l10n.profilePlanFreeBadge;
    }

    final primaryGreen = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Free Plan Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings Section
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              l10n.settingsTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),

          // Settings Options Card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.tune_outlined,
                  title: l10n.profilePreferencesTitle,
                  onTap: () => context.push('/profile/preferences'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.email_outlined,
                  title: l10n.profileChangeEmailLabel,
                  onTap: () => context.push('/profile/change-email'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.public_outlined,
                  title: l10n.profileLanguageTitle,
                  onTap: () => context.push('/profile/language'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.payments_outlined,
                  title: l10n.profilePaymentsTitle,
                  onTap: () => context.push('/profile/view-payments'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.subscriptions_outlined,
                  title: l10n.profileSubscriptionTitle,
                  onTap: () => context.push('/profile/subscription'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_none_outlined,
                  title: l10n.profileNotificationsTitle,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: l10n.profileTermsTitle,
                  showDivider: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),

          // Buttons Section
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: BorderSide(color: primaryGreen, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.logout,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: authState is AuthenticatedAuthState
                ? () => _showDeleteAccountModal(context, ref, email)
                : null,
            child: Text(
              l10n.deleteAccount,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4), size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.05),
    );
  }
}
