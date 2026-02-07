import 'package:formz/formz.dart';
import 'package:meal_plan_app/l10n/app_localizations.dart';

enum NameError { empty }

class Name extends FormzInput<String, NameError> {
  const Name.pure() : super.pure('');
  const Name.dirty(super.value) : super.dirty();

  String? getErrorMessage(AppLocalizations l10n) {
    if (isValid || isPure) return null;

    if (displayError == NameError.empty) return l10n.errorFieldRequired;

    return null;
  }

  @override
  NameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return NameError.empty;
    return null;
  }
}