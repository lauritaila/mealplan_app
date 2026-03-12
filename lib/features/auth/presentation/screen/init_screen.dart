import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/features/shared/widgets/widgets.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

class InitScreen extends ConsumerWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AuthLayout(
      footer: Text(
        l10n.authLegalConsent,
        textAlign: TextAlign.center,
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          AuthHeader(
            title: l10n.authWelcomeTitle,
            subtitle: l10n.authWelcomeSubtitle,
          ),
          const SizedBox(height: 60),
          // Google Sign In
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signInWithGoogle();
              },
              icon: Image.asset(
                'assets/images/google_logo.png',
                width: 24,
                height: 24,
              ),
              label: Text(
                l10n.signInWithGoogle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Register Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CustomFilledButton(
              text: l10n.register,
              buttonColor: colors.primary,
              onPressed: () => context.push('/signup'),
            ),
          ),
          const SizedBox(height: 16),
          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => context.push('/login'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.login,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
