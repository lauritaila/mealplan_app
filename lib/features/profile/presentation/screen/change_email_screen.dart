import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/change_email_provider.dart';
import 'package:meal_plan_app/features/shared/utils/app_error_localizations.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorText)));
      return;
    }

    if (state.otpRequested) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.done)));
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context);
    if (_codeController.text.trim().length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorAuthInvalidOtp)));
      return;
    }

    await ref
        .read(changeEmailProvider.notifier)
        .verifyEmailChangeOtp(
          _emailController.text.trim(),
          _codeController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(changeEmailProvider);
    if (state.error != null) {
      final errorText = localizeAppError(l10n, state.error!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorText)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.done)));
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
    final state = ref.watch(changeEmailProvider);
    final primaryGreen = theme.colorScheme.primary;
    final darkText = theme.colorScheme.onSurface;
    final secondaryText = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          state.otpRequested ? l10n.otpVerifySignIn : l10n.profileChangeEmailLabel,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Icon Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.email_outlined, size: 48, color: primaryGreen),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                state.otpRequested ? 'Check your inbox' : l10n.profileChangeEmailLabel,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.otpRequested
                      ? "We've sent a 6-digit verification code to your new email address. Please enter it below to complete the change."
                      : "Enter your new email address. We'll send a verification code to ensure it's you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondaryText,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              if (!state.otpRequested) ...[
                // Email Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'New Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkText.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'name@example.com',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryGreen, width: 2),
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
                // PIN Input (Simplified for now with 6 boxes but one focus)
                // In a real app, you might use a dedicated PIN widget.
                // Here I'll mock the appearance or use space-between text fields.
                GestureDetector(
                  onTap: () => _codeFocusNode.requestFocus(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final code = _codeController.text;
                      final isFocused = _codeFocusNode.hasFocus && code.length == index;
                      final char = code.length > index ? code[index] : '';

                      return Container(
                        width: 45,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFocused ? primaryGreen : const Color(0xFFE2E8F0),
                            width: isFocused ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char.isEmpty ? '•' : char,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: char.isEmpty ? secondaryText : darkText,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Hidden TextFormField to catch input
                SizedBox(
                  height: 0,
                  width: 0,
                  child: TextFormField(
                    controller: _codeController,
                    focusNode: _codeFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    onChanged: (val) {
                      if (val.length == 6) _verifyCode();
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          state.otpRequested ? l10n.otpVerifySignIn : l10n.continueLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (state.otpRequested)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ", style: TextStyle(color: secondaryText)),
                    GestureDetector(
                      onTap: () => _requestCode(),
                      child: Text(
                        "Resend",
                        style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Secure verification powered by SageAuth',
                  style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
