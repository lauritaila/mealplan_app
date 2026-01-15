import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';
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

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final loginFormState = ref.watch(loginFormProvider);
    final loginFormNotifier = ref.read(loginFormProvider.notifier);

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Center(
        child: AutofillGroup(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
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
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                  AutofillHints.newUsername,
                ],
                onChanged: loginFormNotifier.onEmailChanged,
                errorMessage: loginFormState.isFormPosted
                    ? loginFormState.email.errorMessage
                    : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: CustomFilledButton(
                  text: 'Send Verification Code OTP',
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
                  const Text('Don\'t have an account?'),
                  SizedBox(width: 5),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text('Sign Up'),
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
