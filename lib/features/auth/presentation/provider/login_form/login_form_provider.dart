import 'package:formz/formz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/features/shared/shared.dart';
import '../provider.dart';

part 'login_form_provider.g.dart';

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Email email;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.email = const Email.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Email? email,
  }) => LoginFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    email: email ?? this.email,
  );

  @override
  String toString() {
    return '''
LoginFormState:
  isPosting: $isPosting
  isFormPosted: $isFormPosted
  isValid: $isValid
  email: $email
''';
  }
}

@riverpod
class LoginForm extends _$LoginForm {
  Future<void> signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }

  @override
  LoginFormState build() {
    return LoginFormState();
  }

  void onEmailChanged(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
      email: newEmail,
      isValid: Formz.validate([newEmail]),
    );
  }

  Future<void> onFormSubmitted() async {
    _touchEveryField();

    if (!state.isValid) {
      return;
    }

    state = state.copyWith(isPosting: true);

    try {
      await ref.read(authProvider.notifier).sendOtp(state.email.value);
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }

  void _touchEveryField() {
    final email = Email.dirty(state.email.value);
    state = state.copyWith(
      isFormPosted: true,
      email: email,
      isValid: Formz.validate([email]),
    );
  }
}
