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

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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
    final state = ref.watch(changeEmailProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileChangeEmailLabel)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.profileChangeEmailLabel,
                  hintText: 'example@email.com',
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
              if (state.otpRequested) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: l10n.otpVerificationCodeLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          state.otpRequested
                              ? l10n.done
                              : l10n.profileChangeEmailLabel,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
