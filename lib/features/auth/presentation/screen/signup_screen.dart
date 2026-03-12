import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

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
    final signupFormState = ref.watch(signupFormProvider);
    final signupFormNotifier = ref.read(signupFormProvider.notifier);

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
      // appBarTitle: l10n.register, // "Crear cuenta"
      onBack: () => context.pop(),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.doYouHaveAccount,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          TextButton(
            onPressed: () => context.pushReplacement('/login'),
            child: Text(
              l10n.login,
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
            title: l10n.authWelcome, // "Welcome" / "Bienvenido"
            subtitle: l10n.authSignUpSubtitle,
          ),
          const SizedBox(height: 28),
          CustomTextFormField(
            label: l10n.name,
            hint: l10n.namePlaceholder,
            onChanged: signupFormNotifier.onNameChanged,
            errorMessage: signupFormState.isFormPosted
                ? signupFormState.name.getErrorMessage(l10n)
                : null,
          ),
          const SizedBox(height: 14),
          CustomTextFormField(
            label: l10n.email,
            hint: l10n.emailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            onChanged: signupFormNotifier.onEmailChanged,
            errorMessage: signupFormState.isFormPosted
                ? signupFormState.email.getErrorMessage(l10n)
                : null,
          ),
          const SizedBox(height: 14),
          LegalConsentRichText(
            textTheme: textTheme,
            colors: colors,
            l10n: l10n,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: signupFormState.isPosting
                  ? null
                  : signupFormNotifier.onFormSubmitted,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.sendOtp, // "Enviar OTP"
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
