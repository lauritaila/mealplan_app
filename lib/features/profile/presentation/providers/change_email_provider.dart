import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_repository_provider.dart';

part 'change_email_provider.g.dart';

class ChangeEmailState {
  final bool isLoading;
  final bool otpRequested;
  final AppError? error;

  const ChangeEmailState({
    this.isLoading = false,
    this.otpRequested = false,
    this.error,
  });

  ChangeEmailState copyWith({
    bool? isLoading,
    bool? otpRequested,
    AppError? Function()? error,
  }) {
    return ChangeEmailState(
      isLoading: isLoading ?? this.isLoading,
      otpRequested: otpRequested ?? this.otpRequested,
      error: error != null ? error() : this.error,
    );
  }
}

@riverpod
class ChangeEmail extends _$ChangeEmail {
  @override
  ChangeEmailState build() => const ChangeEmailState();

  Future<void> requestEmailChange(String newEmail) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await ref.read(profileRepositoryProvider).requestEmailChange(newEmail);
      state = state.copyWith(
        isLoading: false,
        otpRequested: true,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e is AppError ? e : const AuthAppError.unexpected(),
      );
    }
  }

  Future<void> verifyEmailChangeOtp(String newEmail, String token) async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      await ref
          .read(profileRepositoryProvider)
          .verifyEmailChangeOtp(newEmail, token);
      await ref.read(authProvider.notifier).refreshUserStatus();
      state = state.copyWith(
        isLoading: false,
        error: () => null,
        otpRequested: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e is AppError ? e : const AuthAppError.unexpected(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }
}
