import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';

import 'profile_repository_provider.dart';

final changeEmailProvider =
    StateNotifierProvider<ChangeEmailController, AsyncValue<void>>((ref) {
      return ChangeEmailController(ref);
    });

class ChangeEmailController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ChangeEmailController(this._ref) : super(const AsyncData(null));

  Future<void> requestEmailChange(String newEmail) async {
    state = const AsyncLoading();
    try {
      await _ref.read(profileRepositoryProvider).requestEmailChange(newEmail);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> verifyEmailChangeOtp(String newEmail, String token) async {
    state = const AsyncLoading();
    try {
      await _ref
          .read(profileRepositoryProvider)
          .verifyEmailChangeOtp(newEmail, token);
      await _ref.read(authProvider.notifier).refreshUserStatus();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
