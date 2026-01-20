import 'package:dio/dio.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/domain.dart';
import '../infrastructure.dart';

class SupabaseDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;
  final Dio _dio;
  final String _userApiBaseUrl;

  SupabaseDatasourceImpl(
    this._supabaseClient, {
    Dio? httpClient,
    String? userApiBaseUrl,
  }) : _userApiBaseUrl = userApiBaseUrl ?? Enviroment.apiBaseUrl,
       _dio =
           httpClient ??
           Dio(
             BaseOptions(
               baseUrl: userApiBaseUrl ?? Enviroment.apiBaseUrl,
               validateStatus: (_) => true,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               sendTimeout: const Duration(seconds: 10),
             ),
           );

  @override
  Future<bool> isAuthenticated() async {
    final session = _supabaseClient.auth.currentSession;
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
    } catch (e) {
      throw const NetworkAppError.noConnection();
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
  Future<void> saveUserPreference(
    UserPreferences userPreference,
    String userId,
  ) async {
    try {
      final preferencesMap = UserPreferencesMapper.toMap(userPreference);
      preferencesMap.remove('id');
      preferencesMap.remove('created_at');
      preferencesMap.remove('updated_at');
      preferencesMap['user_id'] = userId;

      await _supabaseClient.from('user_preferences').upsert(preferencesMap);
      await _supabaseClient
          .from('user_profiles')
          .update({'onboarding_complete': true})
          .eq('id', userId);
    } on PostgrestException {
      throw const DataAppError.updateFailed('user preferences');
    } catch (e) {
      throw const NetworkAppError.noConnection();
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
      final result = await _supabaseClient.rpc(
        'user_exists',
        params: {'p_email': email},
      );
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfile> getAuthenticatedUserProfile() async {
    final supabaseUser = _supabaseClient.auth.currentUser;
    final session = _supabaseClient.auth.currentSession;
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
        '/api/user/profile/${supabaseUser.id}',
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
        'email': supabaseUser.email!,
        'permissions': data['permissions'],
      };

      return UserMapper.fromJson(adjustedProfileData);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkAppError.timeout();
      }

      if (e.type == DioExceptionType.badResponse) {
        final status = e.response?.statusCode ?? -1;
        _throwByStatus(status);
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkAppError.unreachableHost();
      }

      throw const NetworkAppError.serverError();
    } on AppError {
      rethrow;
    } catch (_) {
      throw const NetworkAppError.serverError();
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
      await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on AuthException catch (e) {
      throw AuthAppError(e.message, code: e.statusCode);
    } catch (e) {
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
}
