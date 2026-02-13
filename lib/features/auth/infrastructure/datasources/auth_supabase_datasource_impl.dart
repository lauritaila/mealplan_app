import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_plan_app/config/constants/dio.dart';
import 'package:meal_plan_app/config/constants/storage_keys.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

class AuthSupabaseDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;
  final Dio _dio;
  final String _userApiBaseUrl;
  final FlutterSecureStorage _secureStorage;

  AuthSupabaseDatasourceImpl(
    this._supabaseClient, {
    Dio? httpClient,
    String? userApiBaseUrl,
    FlutterSecureStorage? secureStorage,
  }) : _userApiBaseUrl = userApiBaseUrl ?? Enviroment.apiBaseUrl,
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _dio =
           httpClient ??
           DioFactory.create(
             baseUrl: userApiBaseUrl ?? Enviroment.apiBaseUrl,
             secureStorage: secureStorage,
           );

  @override
  Future<bool> isAuthenticated() async {
    final session = await _ensureSession();
    return session != null && session.accessToken.isNotEmpty;
  }

  @override
  Future<UserProfile> logIn(String email, String password) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final User? supabaseAuthUser = res.user;
      if (supabaseAuthUser == null) {
        throw const AuthAppError.unexpected(
          message: 'Login failed: Could not get user from Supabase.',
        );
      }

      await _persistSession(res.session ?? _supabaseClient.auth.currentSession);

      return _loadUserProfile(supabaseAuthUser.id, supabaseAuthUser.email);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw const AuthAppError.invalidCredentials();
      }
      if (e.message.contains('Email not confirmed')) {
        throw const AuthAppError.emailNotVerified();
      }
      throw const AuthAppError.unexpected();
    } on PostgrestException {
      throw const DataAppError.fetchFailed('user profile');
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> signUp(String email, String password, String name) async {
    try {
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw const AuthAppError.emailAlreadyInUse();
      }
      throw const AuthAppError.unexpected();
    } catch (e) {
      throw const NetworkAppError.noConnection();
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _supabaseClient.auth.signOut();
      await _secureStorage.delete(key: StorageKeys.supabaseAccessToken);
      await _secureStorage.delete(key: StorageKeys.supabaseRefreshToken);
    } catch (e) {
      throw const AuthAppError.unexpected(
        message: 'An unexpected error occurred during logout.',
      );
    }
  }

  @override
  Future<void> signInWithOtp(String email) async {
    try {
      await _supabaseClient.auth.signInWithOtp(email: email);
    } on AuthException {
      throw const AuthAppError.unexpected(message: 'Failed to send OTP.');
    } catch (e) {
      throw const NetworkAppError.noConnection();
    }
  }

  @override
  Future<UserProfile> verifyOtp(String email, String token) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      final User? supabaseAuthUser = res.user;
      if (supabaseAuthUser == null) {
        throw const AuthAppError.unexpected(
          message: 'OTP verification failed: Could not get user from Supabase.',
        );
      }

      await _persistSession(res.session ?? _supabaseClient.auth.currentSession);

      return _loadUserProfile(supabaseAuthUser.id, supabaseAuthUser.email);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid OTP') || e.message.contains('expired')) {
        throw const AuthAppError.invalidOtp();
      }
      throw const AuthAppError.unexpected();
    } catch (e) {
      throw const NetworkAppError.noConnection();
    }
  }

  @override
  Future<void> markOnboardingComplete(String userId) async {
    try {
      String? authUserId = _supabaseClient.auth.currentUser?.id;
      if (authUserId == null) {
        final refreshToken = await _secureStorage.read(
          key: StorageKeys.supabaseRefreshToken,
        );
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _supabaseClient.auth.setSession(refreshToken);
          authUserId = _supabaseClient.auth.currentUser?.id;
        }
      }
      if (authUserId == null) {
        throw const PermissionAppError.unauthorized();
      }
      if (authUserId != userId) {
        throw const PermissionAppError.forbidden();
      }

      await _supabaseClient
          .from('user_profiles')
          .update({'onboarding_complete': true})
          .eq('id', authUserId);
    } on PostgrestException catch (e) {
      final details = [
        if (e.message.isNotEmpty) e.message,
        if (e.details != null && e.details.toString().isNotEmpty)
          e.details.toString(),
        if (e.hint != null && e.hint.toString().isNotEmpty) e.hint.toString(),
      ].join(' | ');
      throw DataAppError(
        details.isNotEmpty
            ? 'Failed to update onboarding status: $details'
            : 'Failed to update onboarding status.',
        code: e.code ?? 'DATA_UPDATE_FAILED',
      );
    } on AppError {
      rethrow;
    } catch (e) {
      throw NetworkAppError('Unexpected error: ${e.toString()}');
    }
  }

  Future<UserProfile> _loadUserProfile(String userId, String? email) async {
    if (email == null) {
      throw const AuthAppError.unexpected(
        message: 'User email is null. Cannot load profile.',
      );
    }
    try {
      final currentUser = _supabaseClient.auth.currentUser;

      final response = await _supabaseClient
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      Map<String, dynamic> profileRow = response ?? {};

      // If the profile doesn't exist yet (e.g., first Google sign-in), create a minimal one.
      if (response == null) {
        final inferredName =
            (currentUser?.userMetadata?['full_name'] as String?) ??
            (currentUser?.userMetadata?['name'] as String?);
        final avatarUrl = currentUser?.userMetadata?['avatar_url'] as String?;

        final insertPayload = {
          'id': userId,
          'name': inferredName,
          'profile_data': avatarUrl != null ? {'avatar_url': avatarUrl} : null,
          // onboarding_complete defaults to false in DB
        };

        profileRow = await _supabaseClient
            .from('user_profiles')
            .insert(insertPayload)
            .select()
            .single();
      }

      return UserMapper.fromJson({...profileRow, 'email': email});
    } on PostgrestException {
      throw const DataAppError.fetchFailed('user profile');
    } catch (e) {
      throw const AuthAppError.unexpected(
        message: 'An unexpected error occurred while loading profile.',
      );
    }
  }

  @override
  Future<bool> userExists(String email) async {
    try {
      try {
        final activeResult = await _supabaseClient.rpc(
          'user_exists_with_active_subscription',
          params: {'p_email': email},
        );
        return activeResult as bool;
      } on PostgrestException {
        final result = await _supabaseClient.rpc(
          'user_exists',
          params: {'p_email': email},
        );
        return result as bool;
      }
    } on PostgrestException catch (e) {
      print('userExists check failed: ${e.message}');
      return false;
    } catch (e) {
      print('userExists unexpected error: $e');
      return false;
    }
  }

  @override
  Future<UserProfile> getAuthenticatedUserProfile() async {
    final session = await _ensureSession();
    final supabaseUser = _supabaseClient.auth.currentUser;
    if (supabaseUser == null || supabaseUser.email == null) {
      throw const PermissionAppError.unauthorized();
    }
    if (session == null || session.accessToken.isEmpty) {
      throw const PermissionAppError.unauthorized();
    }

    try {
      if (_userApiBaseUrl.startsWith('No configure')) {
        throw const ConfigAppError.missing('API_BASE_URL');
      }

      final response = await _dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      final status = response.statusCode ?? 200;
      if (status < 200 || status >= 300) {
        _throwByStatus(status);
      }

      final data = response.data;
      if (data == null) {
        throw const DataAppError.emptyResponse('user profile');
      }

      if (data is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('user profile');
      }

      final profileData = data['profile'];
      if (profileData == null || profileData is! Map<String, dynamic>) {
        throw const DataAppError.serializationFailed('user profile');
      }

      final adjustedProfileData = {
        'id': profileData['id'],
        'name': profileData['name'],
        'profile_data': profileData['profileData'],
        'onboarding_complete': profileData['onboardingComplete'],
        'plan_name': profileData['planName'],
        'configurations': profileData['configurations'],
        'email': supabaseUser.email!,
        'permissions': data['permissions'],
      };

      return UserMapper.fromJson(adjustedProfileData);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _loadUserProfile(supabaseUser.id, supabaseUser.email);
      }

      if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode ?? -1;
        if (status == 401 || status == 403) {
          _throwByStatus(status);
        }
        return _loadUserProfile(supabaseUser.id, supabaseUser.email);
      }

      if (e.type == DioExceptionType.connectionError) {
        return _loadUserProfile(supabaseUser.id, supabaseUser.email);
      }

      return _loadUserProfile(supabaseUser.id, supabaseUser.email);
    } on AppError catch (e) {
      if (e is PermissionAppError || e is AuthAppError) {
        rethrow;
      }
      return _loadUserProfile(supabaseUser.id, supabaseUser.email);
    } catch (_) {
      return _loadUserProfile(supabaseUser.id, supabaseUser.email);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final webClientId = Enviroment.webClientId;
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: webClientId);

      final googleUser = await googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AuthAppError.unexpected(message: 'No ID Token found.');
      }
      final res = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      await _persistSession(res.session ?? _supabaseClient.auth.currentSession);
    } on GoogleSignInException catch (e) {
      if (e.code == 'canceled') {
        print('Google sign-in canceled by user');
        throw AuthAppError('Google sign-in canceled by user', code: 'canceled');
      } else {
        print('Google sign-in error: ${e.toString()}');
        throw AuthAppError('Google sign-in error: ${e.toString()}');
      }
    } on AuthException catch (e) {
      throw AuthAppError(e.message, code: e.statusCode);
    } catch (e) {
      print('Google sign-in unexpected error: $e');
      throw AuthAppError.unexpected(message: e.toString());
    }
  }

  Never _throwByStatus(int statusCode) {
    if (statusCode == 400) throw const NetworkAppError.badRequest();
    if (statusCode == 401) throw const PermissionAppError.unauthorized();
    if (statusCode == 403) throw const PermissionAppError.forbidden();
    if (statusCode == 404) throw const DataAppError.notFound('user profile');
    if (statusCode == 409) {
      throw const DataAppError.updateFailed('user profile');
    }
    if (statusCode == 429) throw const NetworkAppError.tooManyRequests();
    if (statusCode >= 500 && statusCode < 600) {
      throw const NetworkAppError.serverError();
    }
    throw const NetworkAppError.badResponse();
  }

  Future<void> _persistSession(Session? session) async {
    final accessToken = session?.accessToken;
    final refreshToken = session?.refreshToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      await _secureStorage.write(
        key: StorageKeys.supabaseAccessToken,
        value: accessToken,
      );
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.write(
        key: StorageKeys.supabaseRefreshToken,
        value: refreshToken,
      );
    }
  }

  Future<Session?> _ensureSession() async {
    var session = _supabaseClient.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      return session;
    }

    final refreshToken = await _secureStorage.read(
      key: StorageKeys.supabaseRefreshToken,
    );
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _supabaseClient.auth.setSession(refreshToken);
      } catch (_) {
        return null;
      }
    }

    session = _supabaseClient.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      await _persistSession(session);
    }

    return session;
  }
}
