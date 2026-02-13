import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'package:meal_plan_app/features/profile/presentation/providers/profile_provider.dart';

import 'profile_repository_provider.dart';

final languageSettingsProvider =
    StateNotifierProvider<LanguageSettingsController, AsyncValue<void>>((ref) {
      return LanguageSettingsController(ref);
    });

class LanguageSettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LanguageSettingsController(this._ref) : super(const AsyncData(null));

  Future<void> updateLanguage(String langCode) async {
    final authState = _ref.read(authProvider);
    if (authState is! AuthenticatedAuthState) {
      throw const PermissionAppError.unauthorized();
    }

    state = const AsyncLoading();
    try {
      await _ref.read(profileRepositoryProvider).updateLanguage(
            authState.user.id,
            langCode,
          );
      await _ref.read(appLocaleProvider.notifier).setLanguageCode(langCode);
      _ref.read(profileProvider.notifier).setLanguageCode(langCode);
      await _ref.read(authProvider.notifier).refreshUserStatus();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
