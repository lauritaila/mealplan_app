import 'dart:async';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/domain/domain.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final AuthRepository _authRepository;
  StreamSubscription<sb.AuthState>? _authSubscription;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    _authSubscription?.cancel();
    _authSubscription = sb.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          if (data.event == sb.AuthChangeEvent.signedOut) {
            state = const UnauthenticatedAuthState();
          } else if (data.event == sb.AuthChangeEvent.signedIn ||
              data.event == sb.AuthChangeEvent.tokenRefreshed) {
            refreshUserStatus(); // reload profile on restored/updated session
          }
        });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Try to restore any persisted session as soon as the provider builds.
    Future.microtask(refreshUserStatus);

    return const LoadingAuthState();
  }

  // --- AÑADIMOS EL MÉTODO PARA GOOGLE SIGN-IN ---
  Future<void> signInWithGoogle() async {
    state = const LoadingAuthState();
    try {
      await _authRepository.signInWithGoogle();
      await refreshUserStatus();
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    } catch (e) {
      state = const ErrorAuthState(code: 'AUTH_GOOGLE_SIGN_IN_FAILED');
    }
  }
  // --- FIN DEL MÉTODO AÑADIDO ---

  Future<void> checkInitialStatus() async {
    if (state is! InitialAuthState) return;
    await refreshUserStatus();
  }

  Future<void> login(String email, String password) async {
    state = const LoadingAuthState();
    try {
      final user = await _authRepository.logIn(email, password);
      state = AuthenticatedAuthState(user);
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    } catch (e) {
      state = const ErrorAuthState(code: 'AUTH_UNEXPECTED');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const LoadingAuthState();
    try {
      await _authRepository.signUp(email, password, name);
      await _authRepository.logOut();
      await _authRepository.signInWithOtp(email);
      state = AwaitingOtpInputState(email);
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    } catch (e) {
      state = const ErrorAuthState(code: 'AUTH_UNEXPECTED');
    }
  }

  Future<void> sendOtp(String email) async {
    state = const LoadingAuthState();
    try {
      final exists = await _authRepository.userExists(email);
      if (!exists) {
        throw const AuthAppError.userNotFound();
      }
      await _authRepository.signInWithOtp(email);
      state = AwaitingOtpInputState(email);
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    } catch (e) {
      state = const ErrorAuthState(code: 'AUTH_SEND_OTP_FAILED');
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    state = const LoadingAuthState();
    try {
      final userProfile = await _authRepository.verifyOtp(email, token);
      state = AuthenticatedAuthState(userProfile);
    } on AppError catch (e) {
      state = AwaitingOtpInputState(
        email,
        errorMessage: e.message,
        errorCode: e.code,
      );
    } catch (e) {
      state = AwaitingOtpInputState(email, errorCode: 'AUTH_UNEXPECTED');
    }
  }

  Future<void> logOut() async {
    try {
      await _authRepository.logOut();
      state = const UnauthenticatedAuthState();
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    }
  }

  void markOnboardingComplete() {
    final current = state;
    if (current is AuthenticatedAuthState) {
      state = AuthenticatedAuthState(
        current.user.copyWith(onboardingComplete: true),
      );
    }
  }

  void cancelOtpFlow() {
    state = const UnauthenticatedAuthState();
  }

  Future<void> refreshUserStatus() async {
    try {
      final user = await _authRepository.getAuthenticatedUserProfile();
      state = AuthenticatedAuthState(user);
    } catch (_) {
      final session = sb.Supabase.instance.client.auth.currentSession;
      final currentUser = sb.Supabase.instance.client.auth.currentUser;
      if (state is AuthenticatedAuthState) {
        return;
      }
      if (session != null && currentUser != null) {
        return;
      }
      state = const UnauthenticatedAuthState();
    }
  }
}
