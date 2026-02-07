import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final authState = ref.read(authProvider);
    if (authState is AwaitingOtpInputState && _otpController.text.isNotEmpty) {
      ref
          .read(authProvider.notifier)
          .verifyOtp(authState.email, _otpController.text.trim());
    }
  }

  void _onResend() {
    final authState = ref.read(authProvider);
    if (authState is AwaitingOtpInputState) {
      ref.read(authProvider.notifier).sendOtp(authState.email);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).otpSentSnack)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(authProvider, (previous, next) {
      if (next is ErrorAuthState) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                localizeErrorCode(l10n, next.code, fallback: next.message),
              ),
            ),
          );
        _otpController.clear();
      }
    });

    final authState = ref.watch(authProvider);
    final bool isLoading = authState is LoadingAuthState;
    final String email = (authState is AwaitingOtpInputState)
        ? authState.email
        : '...';
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: isLoading
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(authProvider.notifier).cancelOtpFlow();
                },
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.password_rounded, size: 80, color: colors.primary),
            const SizedBox(height: 24),
            Text(
              l10n.otpEnterTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.otpEnterSubtitle,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: l10n.otpVerificationCodeLabel,
                hintText: '______',
                counterText: "",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 22, letterSpacing: 12),
              onFieldSubmitted: (_) => _onSubmit(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : _onResend,
              child: Text(l10n.otpResend),
            ),
            const SizedBox(height: 12),
            CustomFilledButton(
              text: l10n.otpVerifySignIn,
              buttonColor: colors.primary,
              onPressed: isLoading ? null : _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
