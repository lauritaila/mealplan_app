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
  final textTheme = theme.textTheme;
  final customColors = theme.extension<AppCustomColors>()!;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.deleteAccount,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.confirmDeleteWithEmail(email),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: customColors.slateGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: customColors.textDarkBlue),
                decoration: InputDecoration(
                  hintText: 'email@example.com',
                  hintStyle: textTheme.bodyLarge?.copyWith(color: customColors.slateGrey?.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: customColors.chartTabBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          content: Row(
                            children: [
                              CircularProgressIndicator(color: customColors.darkSage),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Text(
                                  l10n.profileFarewell,
                                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
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
                    if (context.mounted) context.go('/init');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    l10n.deleteAccount,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  l10n.cancel,
                  style: textTheme.labelLarge?.copyWith(
                    color: customColors.slateGrey,
                    fontWeight: FontWeight.w900,
                  ),
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
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
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
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: customColors.chartTabBackground?.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Plan Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: customColors.darkSage,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    planName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  displayName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: customColors.textDarkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: textTheme.bodyMedium?.copyWith(
                    color: customColors.slateGrey,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Settings Section
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              l10n.settingsTitle.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: customColors.slateGrey?.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Settings Options Card
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
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
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.email_outlined,
                  title: l10n.profileChangeEmailLabel,
                  onTap: () => context.push('/profile/change-email'),
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.public_outlined,
                  title: l10n.profileLanguageTitle,
                  onTap: () => context.push('/profile/language'),
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.payments_outlined,
                  title: l10n.profilePaymentsTitle,
                  onTap: () => context.push('/profile/view-payments'),
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.subscriptions_outlined,
                  title: l10n.profileSubscriptionTitle,
                  onTap: () => context.push('/profile/subscription'),
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: l10n.profileTermsTitle,
                  onTap: () => context.push('/terms-and-conditions'),
                ),
                _buildDivider(theme),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.profilePrivacyTitle,
                  onTap: () => context.push('/privacy-policy'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 56),

          // Buttons Section
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logOut();
                if (context.mounted) context.go('/init');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: customColors.darkSage,
                side: BorderSide(color: customColors.darkSage!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.logout,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: authState is AuthenticatedAuthState
                ? () => _showDeleteAccountModal(context, ref, email)
                : null,
            child: Text(
              l10n.deleteAccount,
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              '© 2026 Meal Plan App',
              style: textTheme.labelSmall?.copyWith(
                color: customColors.slateGrey?.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
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
  }) {
    final theme = Theme.of(context);
    final customColors = theme.extension<AppCustomColors>()!;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: customColors.chartTabBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: customColors.darkSage, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: customColors.textDarkBlue,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: customColors.slateGrey?.withValues(alpha: 0.3), size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: theme.dividerColor.withValues(alpha: 0.05),
    );
  }
}
