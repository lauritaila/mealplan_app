import 'dart:async';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_repository_provider.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/domain/domain.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  static final Logger _logger = Logger('AuthProvider');
  late final AuthRepository _authRepository;
  StreamSubscription<sb.AuthState>? _authSubscription;
  String? _pendingGracePeriodEmail;
  bool _pendingGraceWelcome = false;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    _authSubscription?.cancel();
    _authSubscription = sb.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          if (data.event == sb.AuthChangeEvent.signedOut) {
            _pendingGracePeriodEmail = null;
            _pendingGraceWelcome = false;
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
      final accessStatus = await _authRepository.signInWithGoogle();
      final user = await _authRepository.getAuthenticatedUserProfile();

      if (accessStatus == AccessStatus.gracePeriod) {
        await _reactivateAccount(user.id);
        _pendingGraceWelcome = true;
      }

      await ref
          .read(appLocaleProvider.notifier)
          .syncFromRemote(user.configurations?['language'] as String?);
      state = AuthenticatedAuthState(
        user,
        showGraceWelcome: _pendingGraceWelcome,
      );
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

  //no se usa en ningún sitio, pero lo dejo por si acaso queremos forzar un refresh del estado del usuario desde algún sitio
  Future<void> login(String email, String password) async {
    state = const LoadingAuthState();
    try {
      final user = await _authRepository.logIn(email, password);
      await ref
          .read(appLocaleProvider.notifier)
          .syncFromRemote(user.configurations?['language'] as String?);
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
      _pendingGracePeriodEmail = null;
      _pendingGraceWelcome = false;
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

  //verdadero login con OTP
  Future<void> sendOtp(String email) async {
    state = const LoadingAuthState();
    try {
      final accessStatus = await _authRepository.getUserAccessStatus(email);
      if (!accessStatus.canLogIn) {
        _pendingGracePeriodEmail = null;
        throw const AuthAppError.userNotFound();
      }

      final isGracePeriod = accessStatus == AccessStatus.gracePeriod;
      _pendingGracePeriodEmail = isGracePeriod ? email : null;

      await _authRepository.signInWithOtp(email);
      state = AwaitingOtpInputState(email, cameFromGracePeriod: isGracePeriod);
    } on AppError catch (e) {
      state = ErrorAuthState(message: e.message, code: e.code);
    } catch (e) {
      state = const ErrorAuthState(code: 'AUTH_SEND_OTP_FAILED');
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    final previousState = state;
    final isGracePeriod =
        (previousState is AwaitingOtpInputState &&
            previousState.cameFromGracePeriod) ||
        (_pendingGracePeriodEmail != null &&
            _pendingGracePeriodEmail!.toLowerCase() == email.toLowerCase());

    state = const LoadingAuthState();
    try {
      final userProfile = await _authRepository.verifyOtp(email, token);
      if (isGracePeriod) {
        await _reactivateAccount(userProfile.id);
        _pendingGraceWelcome = true;
      }

      _pendingGracePeriodEmail = null;
      await ref
          .read(appLocaleProvider.notifier)
          .syncFromRemote(userProfile.configurations?['language'] as String?);
      state = AuthenticatedAuthState(
        userProfile,
        showGraceWelcome: _pendingGraceWelcome,
      );
    } on AppError catch (e) {
      state = AwaitingOtpInputState(
        email,
        errorMessage: e.message,
        errorCode: e.code,
        cameFromGracePeriod: isGracePeriod,
      );
    } catch (e) {
      state = AwaitingOtpInputState(
        email,
        errorCode: 'AUTH_UNEXPECTED',
        cameFromGracePeriod: isGracePeriod,
      );
    }
  }

  Future<void> logOut() async {
    try {
      await _authRepository.logOut();
      _pendingGracePeriodEmail = null;
      _pendingGraceWelcome = false;
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
        showGraceWelcome: current.showGraceWelcome,
      );
    }
  }

  void consumeGraceWelcome() {
    final current = state;
    if (current is AuthenticatedAuthState && current.showGraceWelcome) {
      _pendingGraceWelcome = false;
      state = AuthenticatedAuthState(current.user);
    }
  }

  void cancelOtpFlow() {
    _pendingGracePeriodEmail = null;
    state = const UnauthenticatedAuthState();
  }

  Future<void> _reactivateAccount(String userId) async {
    try {
      await ref
          .read(profileRepositoryProvider)
          .reactivateAccount(userId: userId);
    } catch (e, st) {
      _logger.severe('Automatic reactivation failed', e, st);
    }
  }

  Future<void> refreshUserStatus() async {
    try {
      try {
        await sb.Supabase.instance.client.auth.getUser();
      } catch (e, st) {
        _logger.warning('auth.getUser() refresh failed', e, st);
      }

      final user = await _authRepository.getAuthenticatedUserProfile();
      await ref
          .read(appLocaleProvider.notifier)
          .syncFromRemote(user.configurations?['language'] as String?);
      final shouldShowGraceWelcome =
          _pendingGraceWelcome ||
          (state is AuthenticatedAuthState &&
              (state as AuthenticatedAuthState).showGraceWelcome);
      state = AuthenticatedAuthState(
        user,
        showGraceWelcome: shouldShowGraceWelcome,
      );
    } catch (_) {
      final session = sb.Supabase.instance.client.auth.currentSession;
      final currentUser = sb.Supabase.instance.client.auth.currentUser;
      if (state is AuthenticatedAuthState) {
        return;
      }
      if (session != null && currentUser != null) {
        return;
      }
      _pendingGraceWelcome = false;
      state = const UnauthenticatedAuthState();
    }
  }
}
