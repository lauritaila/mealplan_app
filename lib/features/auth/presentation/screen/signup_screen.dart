// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:meal_plan_app/features/shared/shared.dart';
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
    final signupFormState = ref.watch(signupFormProvider);
    final signupFormNotifier = ref.read(signupFormProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next is ErrorAuthState) {
        showSnackbar(context, next.message);
      }
      if (previous is LoadingAuthState && next is AwaitingOtpInputState) {
        showSnackbar(
          context,
          'A verification code has been sent to your email.',
        );
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
                        const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.usb_rounded), 
                label: const Text('Sign in with Google'),
                onPressed: () {
              ref.read(authProvider.notifier).signInWithGoogle();
                },
                style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black, backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.grey),
              ),
                ),
              ),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Name',
              onChanged: signupFormNotifier.onNameChanged,
              errorMessage: signupFormState.isFormPosted
                  ? signupFormState.name.errorMessage
                  : null,
            ),
            const SizedBox(height: 15),
            CustomTextFormField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              onChanged: signupFormNotifier.onEmailChanged,
              errorMessage: signupFormState.isFormPosted
                  ? signupFormState.email.errorMessage
                  : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: CustomFilledButton(
                text: 'Send OTP',
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
                const Text('Do you have an account?'),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
