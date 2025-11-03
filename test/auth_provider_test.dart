import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/core/supabase/supabase_provider.dart';

import 'package:meal_plan_app/features/auth/presentation/provider/auth/auth_provider.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/auth/auth_state.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/repository/repository_provider.dart';
import 'package:meal_plan_app/features/auth/infrastructure/repositories/repository_impl.dart';
import 'package:meal_plan_app/features/auth/domain/datasources/auth_datasource.dart';
import 'package:meal_plan_app/features/auth/domain/entities/user.dart';
import 'package:meal_plan_app/config/errors/app_errors.dart';

class FakeAuthDatasource implements AuthDatasource {
  bool _authenticated = false;
  final UserProfile testUser;

  // Flags to simulate error scenarios
  final bool throwOnLogin;
  final bool throwOnVerifyOtp;
  final bool throwOnGoogleSignIn;

  FakeAuthDatasource({
    required this.testUser,
    bool initiallyAuthenticated = false,
    this.throwOnLogin = false,
    this.throwOnVerifyOtp = false,
    this.throwOnGoogleSignIn = false,
  }) {
    _authenticated = initiallyAuthenticated;
  }

  @override
  Future<UserProfile> getAuthenticatedUserProfile() async {
    if (!_authenticated) throw Exception('No authenticated');
    return testUser;
  }

  @override
  Future<UserProfile> logIn(String email, String password) async {
    if (throwOnLogin) {
      throw const AuthAppError.invalidCredentials();
    }
    _authenticated = true;
    return testUser;
  }

  @override
  Future<void> logOut() async {
    _authenticated = false;
  }

  // Unused in these tests; provide simple implementations
  @override
  Future<bool> isAuthenticated() async => _authenticated;

  @override
  Future<void> saveUserPreference(userPreference, String userId) async {}

  @override
  Future<void> signInWithGoogle() async {
    if (throwOnGoogleSignIn) throw const AuthAppError.unexpected();
    _authenticated = true;
  }

  @override
  Future<void> signInWithOtp(String email) async {}

  @override
  Future<UserProfile> verifyOtp(String email, String token) async {
    if (throwOnVerifyOtp) throw const AuthAppError.invalidOtp();
    _authenticated = true;
    return testUser;
  }

  @override
  Future<void> signUp(String email, String password, String name) async {}

  @override
  Future<bool> userExists(String email) async => true;
}

void main() {
  final dummyUser = UserProfile(
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    onboardingComplete: true,
    profileData: null,
  );

  test('checkInitialStatus sets AuthenticatedAuthState when datasource reports session', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, initiallyAuthenticated: true);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);

    addTearDown(container.dispose);

    // Initially should be InitialAuthState
    final initial = container.read(authProvider);
    expect(initial.runtimeType.toString(), contains('InitialAuthState'));

    // Call checkInitialStatus
    await container.read(authProvider.notifier).checkInitialStatus();

    final state = container.read(authProvider);
    expect(state.runtimeType.toString(), contains('AuthenticatedAuthState'));
    final authState = state as AuthenticatedAuthState;
    expect(authState.user, equals(dummyUser));
  });

  test('login transitions to AuthenticatedAuthState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, initiallyAuthenticated: false);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);

    addTearDown(container.dispose);

    final notifier = container.read(authProvider.notifier);

    final future = notifier.login('test@example.com', 'pwd');

    // After calling login, state should eventually be AuthenticatedAuthState
    await future;

    final state = container.read(authProvider);
    expect(state, isA<AuthenticatedAuthState>());
    final authState = state as AuthenticatedAuthState;
    expect(authState.user.email, equals('test@example.com'));
  });

  test('logOut transitions to UnauthenticatedAuthState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, initiallyAuthenticated: true);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);

    addTearDown(container.dispose);

    // ensure authenticated first
    await container.read(authProvider.notifier).checkInitialStatus();
    expect(container.read(authProvider), isA<AuthenticatedAuthState>());

    await container.read(authProvider.notifier).logOut();

    expect(container.read(authProvider), isA<UnauthenticatedAuthState>());
  });

  test('login with invalid credentials sets ErrorAuthState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, throwOnLogin: true);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login('bad@example.com', 'bad');

    final state = container.read(authProvider);
    expect(state, isA<ErrorAuthState>());
    final error = state as ErrorAuthState;
    expect(error.message, contains('Invalid credentials'));
  });

  test('verifyOtp with invalid token returns to AwaitingOtpInputState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, throwOnVerifyOtp: true);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).verifyOtp('test@example.com', '0000');

    final state = container.read(authProvider);
    expect(state, isA<AwaitingOtpInputState>());
  });

  test('signInWithGoogle success leads to AuthenticatedAuthState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, throwOnGoogleSignIn: false);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).signInWithGoogle();

    final state = container.read(authProvider);
    expect(state, isA<AuthenticatedAuthState>());
  });

  test('signInWithGoogle error sets ErrorAuthState', () async {
    final fake = FakeAuthDatasource(testUser: dummyUser, throwOnGoogleSignIn: true);
    final repo = AuthRepositoryImpl(fake);

    final container = ProviderContainer(overrides: [
      supabaseClientProvider.overrideWithValue(null),
      authRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).signInWithGoogle();

    final state = container.read(authProvider);
    expect(state, isA<ErrorAuthState>());
  });
}
