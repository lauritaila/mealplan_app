import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/config.dart';
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
  bool _loading = false;
  bool _otpRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(changeEmailProvider.notifier)
          .requestEmailChange(_emailController.text.trim());
      setState(() => _otpRequested = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.done)),
      );
    } on AppError catch (e) {
      if (!mounted) return;
      final errorText = localizeAppError(l10n, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context);
    if (_codeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorAuthInvalidOtp)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ref.read(changeEmailProvider.notifier).verifyEmailChangeOtp(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.done)));
      Navigator.of(context).pop();
    } on AppError catch (e) {
      if (!mounted) return;
      final errorText = localizeAppError(l10n, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_otpRequested) {
      await _verifyCode();
      return;
    }
    await _requestCode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              if (_otpRequested) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Código de 6 dígitos',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(_otpRequested ? l10n.done : l10n.profileChangeEmailLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
