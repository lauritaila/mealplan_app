import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

import '../../../shared/shared.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import '../provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _LoginForm());
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Center(
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.login,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 24,
                  height: 24,
                  semanticLabel: 'Google logo',
                ),
                label: Text(l10n.signInWithGoogle),
                onPressed: loginFormState.isPosting
                    ? null
                    : loginFormNotifier.signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: l10n.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                  AutofillHints.newUsername,
                ],
                onChanged: loginFormNotifier.onEmailChanged,
                errorMessage: loginFormState.isFormPosted
                    ? loginFormState.email.getErrorMessage(l10n)
                    : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: CustomFilledButton(
                  text: l10n.sendVerificationCodeOtp,
                  buttonColor: colors.primary,
                  onPressed: loginFormState.isPosting
                      ? null
                      : loginFormNotifier.onFormSubmitted,
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.dontHaveAccount),
                  SizedBox(width: 5),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: Text(l10n.signUp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
