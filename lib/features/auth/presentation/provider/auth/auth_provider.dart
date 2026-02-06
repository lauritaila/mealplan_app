import 'dart:async';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/core/supabase/auth_state_changes_provider.dart';
import 'package:meal_plan_app/features/auth/domain/domain.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final AuthRepository _authRepository;
    // StreamSubscription<dynamic>? _authSubscription;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    // Listen to auth state change stream provided by the authStateChanges provider.
      // Use ref.listen so Riverpod handles subscription lifecycle in tests and production.
      ref.listen<AsyncValue<dynamic>>(authStateChangesProvider, (previous, next) {
        final value = next.asData?.value;
        if (value != null) {
          final event = value.event;
          if (event == sb.AuthChangeEvent.signedOut) {
            state = const UnauthenticatedAuthState();
          }
        }
      });

    ref.onDispose(() {
        // _authSubscription?.cancel();
    });

    return const InitialAuthState();
  }
  
  // --- AÑADIMOS EL MÉTODO PARA GOOGLE SIGN-IN ---
  Future<void> signInWithGoogle() async {
    state = const LoadingAuthState();
    try {
      // 1. Llama al repositorio para realizar el inicio de sesión con Google.
      await _authRepository.signInWithGoogle();
      
      // 2. ¡LA CORRECCIÓN CLAVE! Después de un inicio de sesión exitoso,
      //    refrescamos el estado del usuario. Esto actualizará el estado a
      //    AuthenticatedAuthState y activará la redirección de GoRouter.
      await refreshUserStatus();

    } on AppError catch (e) {
      state = ErrorAuthState(e.message);
    } catch (e) {
      state = const ErrorAuthState('An unexpected error occurred during Google Sign-In.');
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
      state = ErrorAuthState(e.message);
    } catch (e) {
      state = const ErrorAuthState('An unexpected error occurred.');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const LoadingAuthState();
    try {
      await _authRepository.signUp(email, password, name);
      await _authRepository.signInWithOtp(email);
      state = AwaitingOtpInputState(email);
    } on AppError catch (e) {
      state = ErrorAuthState(e.message);
    } catch (e) {
      state = const ErrorAuthState('An unexpected error occurred during sign up.');
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
      state = ErrorAuthState(e.message);
    } catch (e) {
      state = const ErrorAuthState('Failed to send OTP. Please try again.');
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    state = const LoadingAuthState();
    try {
      final userProfile = await _authRepository.verifyOtp(email, token);
      state = AuthenticatedAuthState(userProfile);
    } on AppError catch (e) {
      state = ErrorAuthState(e.message);
      state = AwaitingOtpInputState(email);
    } catch (e) {
      state = const ErrorAuthState('An unexpected error occurred.');
      state = AwaitingOtpInputState(email);
    }
  }

  Future<void> logOut() async {
    try {
      await _authRepository.logOut();
      state = const UnauthenticatedAuthState();
    } on AppError catch (e) {
      state = ErrorAuthState(e.message);
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
      state = const UnauthenticatedAuthState();
    }
  }
}
