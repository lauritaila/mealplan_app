import 'package:meal_plan_app/config/config.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/domain.dart';
import '../infrastructure.dart';

class SupabaseDatasourceImpl implements AuthDatasource {
  final SupabaseClient _supabaseClient;

  SupabaseDatasourceImpl(this._supabaseClient);

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
    if (supabaseUser == null || supabaseUser.email == null) {
      throw const PermissionAppError.unauthorized();
    }
    return _loadUserProfile(supabaseUser.id, supabaseUser.email);
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
}
