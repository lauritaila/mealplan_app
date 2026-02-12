// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import '../provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _SignUpForm());
  }
}

class _SignUpForm extends ConsumerWidget {
  const _SignUpForm();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final signupFormState = ref.watch(signupFormProvider);
    final signupFormNotifier = ref.read(signupFormProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next is ErrorAuthState) {
        showSnackbar(
          context,
          localizeErrorCode(l10n, next.code, fallback: next.message),
        );
      }
      if (previous is LoadingAuthState && next is AwaitingOtpInputState) {
        showSnackbar(context, l10n.verificationCodeSentEmail);
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.signUp,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text(l10n.signInWithGoogle),
              onPressed: () {
                ref.read(authProvider.notifier).signInWithGoogle();
              },
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
              label: l10n.name,
              onChanged: signupFormNotifier.onNameChanged,
              errorMessage: signupFormState.isFormPosted
                  ? signupFormState.name.getErrorMessage(l10n)
                  : null,
            ),
            const SizedBox(height: 15),
            CustomTextFormField(
              label: l10n.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: signupFormNotifier.onEmailChanged,
              errorMessage: signupFormState.isFormPosted
                  ? signupFormState.email.getErrorMessage(l10n)
                  : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: CustomFilledButton(
                text: l10n.sendOtp,
                buttonColor: colors.primary,
                onPressed: signupFormState.isPosting
                    ? null
                    : signupFormNotifier.onFormSubmitted,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.doYouHaveAccount),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.login),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
