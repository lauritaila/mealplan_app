import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';

import 'profile_repository_provider.dart';

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountController, AsyncValue<void>>((ref) {
      return DeleteAccountController(ref);
    });

class DeleteAccountController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  DeleteAccountController(this._ref) : super(const AsyncData(null));

  Future<void> deleteAccount(String confirmationEmail) async {
    final authState = _ref.read(authProvider);
    if (authState is! AuthenticatedAuthState) {
      throw const PermissionAppError.unauthorized();
    }

    state = const AsyncLoading();
    try {
      await _ref.read(profileRepositoryProvider).softDeleteAccount(
            userId: authState.user.id,
            email: authState.user.email,
            confirmationEmail: confirmationEmail,
          );
      await _ref.read(authProvider.notifier).logOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
