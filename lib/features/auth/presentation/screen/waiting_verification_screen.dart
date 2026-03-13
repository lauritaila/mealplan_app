import 'package:flutter/services.dart';
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
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
    _codeFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  String get _otpCode => _codeController.text;

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
        _codeController.clear();
        _codeFocusNode.requestFocus();
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
            subtitle: l10n.otpEnterSubtitle(email),
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 48),
          // PIN Input with Overlay TextField
          Stack(
            children: [
              // Visual Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final code = _codeController.text;
                  final isFocused = _codeFocusNode.hasFocus && 
                      (code.length == index || (code.length == 6 && index == 5));
                  final char = code.length > index ? code[index] : '';

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFocused ? colors.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isFocused ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        char.isEmpty ? '•' : char,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: char.isEmpty ? colors.onSurfaceVariant.withValues(alpha: 0.3) : colors.primary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Invisible TextFormField overlaying the boxes
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextFormField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (val) {
                      if (val.length == 6) _onSubmit();
                    },
                  ),
                ),
              ),
            ],
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
