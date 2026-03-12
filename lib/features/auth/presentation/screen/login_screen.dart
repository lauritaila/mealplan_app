import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    if (isError) {
      CustomSnackbar.showError(context, message);
    } else {
      CustomSnackbar.showInfo(context, message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final loginFormState = ref.watch(loginFormProvider);
    final loginFormNotifier = ref.read(loginFormProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next is ErrorAuthState) {
        showSnackbar(
          context,
          localizeErrorCode(l10n, next.code, fallback: next.message),
          isError: true,
        );
      }
      if (previous is LoadingAuthState && next is AwaitingOtpInputState) {
        showSnackbar(context, l10n.verificationCodeSentEmail);
      }
    });

    return AuthLayout(
      // appBarTitle: l10n.login, // "Iniciar sesión"
      onBack: () => context.pop(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.dontHaveAccount,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          TextButton(
            onPressed: () => context.pushReplacement('/signup'),
            child: Text(
              l10n.signUp,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          AuthHeader(
            title: l10n.authWelcomeBackTitle,
            subtitle: l10n.authLoginSubtitle,
          ),
          const SizedBox(height: 28),
          // Google Sign In
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: loginFormState.isPosting
                  ? null
                  : loginFormNotifier.signInWithGoogle,
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
          const SizedBox(height: 32),
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: colors.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.authLoginDivider,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colors.outlineVariant)),
            ],
          ),
          const SizedBox(height: 32),
          CustomTextFormField(
            label: l10n.email,
            hint: l10n.emailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            onChanged: loginFormNotifier.onEmailChanged,
            errorMessage: loginFormState.isFormPosted
                ? loginFormState.email.getErrorMessage(l10n)
                : null,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CustomFilledButton(
              text: l10n.sendVerificationCodeOtp,
              buttonColor: colors.primary,
              onPressed: loginFormState.isPosting
                  ? null
                  : loginFormNotifier.onFormSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
