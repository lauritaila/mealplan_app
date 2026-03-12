import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/features/auth/presentation/widgets/widgets_auth.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onSubmit() {
    final authState = ref.read(authProvider);
    final code = _otpCode;
    if (authState is AwaitingOtpInputState && code.length == 6) {
      ref.read(authProvider.notifier).verifyOtp(authState.email, code.trim());
    }
  }

  void _onResend() {
    final authState = ref.read(authProvider);
    if (authState is AwaitingOtpInputState) {
      ref.read(authProvider.notifier).sendOtp(authState.email);
      CustomSnackbar.showInfo(
        context,
        AppLocalizations.of(context).otpSentSnack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(authProvider, (previous, next) {
      if (next is ErrorAuthState) {
        CustomSnackbar.showError(
          context,
          localizeErrorCode(l10n, next.code, fallback: next.message),
        );
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      }
    });

    final authState = ref.watch(authProvider);
    final bool isLoading = authState is LoadingAuthState;
    final String email = (authState is AwaitingOtpInputState) ? authState.email : '...';

    return AuthLayout(
      appBarTitle: l10n.otpEnterTitle, // "Verificación"
      onBack: isLoading ? null : () => ref.read(authProvider.notifier).cancelOtpFlow(),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.otpVerifyNotReceived,
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          TextButton(
            onPressed: isLoading ? null : _onResend,
            child: Text(
              l10n.authResendCode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          AuthHeader(
            title: l10n.authVerifyAccountTitle,
            subtitle: l10n.otpEnterSubtitle.replaceAll('[email]', email),
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 48),
          // OTP Input Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    fillColor: colors.surfaceContainerHighest.withOpacity(0.1),
                    filled: true,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    if (_otpCode.length == 6) {
                      _onSubmit();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CustomFilledButton(
              text: l10n.otpVerifySignIn, // "Verificar e iniciar sesión"
              buttonColor: colors.primary,
              onPressed: isLoading || _otpCode.length < 6 ? null : _onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
