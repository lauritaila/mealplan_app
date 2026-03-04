import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_repository_provider.dart';

part 'delete_account_provider.g.dart';

@riverpod
class DeleteAccount extends _$DeleteAccount {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> deleteAccount(String confirmationEmail) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthenticatedAuthState) {
      throw const PermissionAppError.unauthorized();
    }

    state = const AsyncLoading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .softDeleteAccount(
            userId: authState.user.id,
            confirmationEmail: confirmationEmail,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
