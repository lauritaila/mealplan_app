import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/change_email_provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';
import 'package:meal_plan_app/config/theme/app_theme.dart';
import 'package:meal_plan_app/features/shared/shared.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      setState(() {});
    });
    _codeFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(changeEmailProvider.notifier)
        .requestEmailChange(_emailController.text.trim());

    if (!mounted) return;
    final state = ref.read(changeEmailProvider);
    if (state.error != null) {
      final errorText = localizeAppError(l10n, state.error!);
      CustomSnackbar.showError(context, errorText);
      return;
    }

    // Success feedback removed as per user request "solo usalos para errores"
  }

  Future<void> _verifyCode() async {
    final state = ref.read(changeEmailProvider);
    if (state.isLoading) return;

    final l10n = AppLocalizations.of(context);
    if (_codeController.text.trim().length != 6) {
      CustomSnackbar.showError(context, l10n.errorAuthInvalidOtp);
      return;
    }

    await ref
        .read(changeEmailProvider.notifier)
        .verifyEmailChangeOtp(
          _emailController.text.trim(),
          _codeController.text.trim(),
        );

    if (!mounted) return;
    final resultState = ref.read(changeEmailProvider);
    if (resultState.error != null) {
      final errorText = localizeAppError(l10n, resultState.error!);
      CustomSnackbar.showError(context, errorText);
      return;
    }

    // Success feedback removed
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    final state = ref.read(changeEmailProvider);
    if (state.otpRequested) {
      await _verifyCode();
      return;
    }
    await _requestCode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = theme.extension<AppCustomColors>()!;
    final state = ref.watch(changeEmailProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          state.otpRequested ? l10n.otpVerifySignIn : l10n.profileChangeEmailLabel,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: customColors.textDarkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Icon Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: customColors.darkSage?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.email_outlined, size: 48, color: customColors.darkSage),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                state.otpRequested ? l10n.checkYourInbox : l10n.profileChangeEmailLabel,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: customColors.textDarkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.otpRequested
                      ? l10n.otpVerificationMessage
                      : l10n.otpRequestMessage,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: customColors.slateGrey,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              if (!state.otpRequested) ...[
                // Email Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.newEmailAddressLabel.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: customColors.slateGrey?.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: customColors.textDarkBlue,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.newEmailPlaceholder,
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: customColors.slateGrey?.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: customColors.chartTabBackground,
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: customColors.darkSage!, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorFieldRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.errorEmailInvalid;
                    }
                    return null;
                  },
                ),
              ] else ...[
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
                            color: customColors.chartTabBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFocused ? customColors.darkSage! : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isFocused ? [
                              BoxShadow(
                                color: customColors.darkSage!.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              char.isEmpty ? '•' : char,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: char.isEmpty ? customColors.slateGrey?.withValues(alpha: 0.3) : customColors.textDarkBlue,
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
                          onChanged: (val) {
                            if (val.length == 6) _verifyCode();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: customColors.darkSage,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Text(
                          state.otpRequested ? l10n.otpVerifySignIn : l10n.continueLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              if (state.otpRequested)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${l10n.didntReceiveCode} ",
                      style: textTheme.bodyMedium?.copyWith(color: customColors.slateGrey),
                    ),
                    GestureDetector(
                      onTap: () => _requestCode(),
                      child: Text(
                        l10n.resendAction,
                        style: textTheme.bodyMedium?.copyWith(
                          color: customColors.darkSage,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
                  l10n.secureVerificationNote,
                  style: textTheme.labelSmall?.copyWith(
                    color: customColors.slateGrey?.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
