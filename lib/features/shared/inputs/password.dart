import 'package:formz/formz.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

// Define input validation errors
enum PasswordError { empty, length, format }

// Extend FormzInput and provide the input type and error type.
class Password extends FormzInput<String, PasswordError> {
  static final RegExp passwordRegExp = RegExp(
    r'(?:(?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$',
  );

  // Call super.pure to represent an unmodified form input.
  const Password.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Password.dirty(super.value) : super.dirty();

  String? getErrorMessage(AppLocalizations l10n) {
    if (isValid || isPure) return null;

    if (displayError == PasswordError.empty) return l10n.errorFieldRequired;
    if (displayError == PasswordError.length) {
      return l10n.errorPasswordMinLength;
    }
    if (displayError == PasswordError.format) return l10n.errorPasswordFormat;

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  PasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return PasswordError.empty;
    if (value.length < 6) return PasswordError.length;
    if (!passwordRegExp.hasMatch(value)) return PasswordError.format;

    return null;
  }
}
