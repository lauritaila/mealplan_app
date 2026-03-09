import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logging/logging.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'profile_repository_provider.dart';

part 'language_settings_provider.g.dart';

final Logger _logger = Logger('LanguageSettings');

class LanguageSettingsState {
  final String selectedCode;
  final String persistedCode;
  final bool isSaving;
  final AppError? error;
  const LanguageSettingsState({
    required this.selectedCode,
    required this.persistedCode,
    this.isSaving = false,
    this.error,
  });

  LanguageSettingsState copyWith({
    String? selectedCode,
    String? persistedCode,
    bool? isSaving,
    AppError? Function()? error,
  }) {
    return LanguageSettingsState(
      selectedCode: selectedCode ?? this.selectedCode,
      persistedCode: persistedCode ?? this.persistedCode,
      isSaving: isSaving ?? this.isSaving,
      error: error != null ? error() : this.error,
    );
  }
}

@riverpod
class LanguageSettings extends _$LanguageSettings {
  @override
  LanguageSettingsState build() {
    final authState = ref.watch(authProvider);
    final persistedCode = authState is AuthenticatedAuthState
        ? (authState.user.configurations?['language'] as String? ?? 'en')
        : 'en';
    return LanguageSettingsState(
      selectedCode: persistedCode,
      persistedCode: persistedCode,
    );
  }

  void select(String code) {
    state = state.copyWith(selectedCode: code, error: () => null);
  }

  Future<void> confirm() async {
    final selected = state.selectedCode;
    final previousCode = state.persistedCode;
    if (state.isSaving || selected == previousCode) return;
    final authState = ref.read(authProvider);
    if (authState is! AuthenticatedAuthState) {
      state = state.copyWith(
        error: () => const PermissionAppError.unauthorized(),
      );
      return;
    }
    state = state.copyWith(isSaving: true, error: () => null);
    try {
      await ref.read(profileRepositoryProvider).updateLanguage(selected);
      // Immediately update persistedCode to reflect backend change
      state = state.copyWith(persistedCode: selected);
      var localLocaleUpdated = false;
      try {
        await ref.read(appLocaleProvider.notifier).setLanguageCode(selected);
        localLocaleUpdated = true;
        // Update UI state immediately to reflect persisted backend change
        state = state.copyWith(isSaving: false, error: () => null);
      } catch (e) {
        // If local update partially applied, try to rollback locale
        if (localLocaleUpdated) {
          try {
            await ref
                .read(appLocaleProvider.notifier)
                .setLanguageCode(previousCode);
          } catch (e, st) {
            _logger.warning(
              'Failed to revert local locale from "$selected" to "$previousCode"',
              e,
              st,
            );
          }
        }

        // Try to rollback server-side persisted language
        try {
          await ref
              .read(profileRepositoryProvider)
              .updateLanguage(previousCode);
        } catch (rollbackError) {
          state = state.copyWith(
            persistedCode: previousCode,
            isSaving: false,
            error: () => rollbackError is AppError
                ? rollbackError
                : const DataAppError.updateFailed('language settings'),
          );
          return;
        }

        state = state.copyWith(
          persistedCode: previousCode,
          isSaving: false,
          error: () => e is AppError
              ? e
              : const DataAppError.updateFailed('language settings'),
        );
        return;
      }

      // Refresh user status but do not revert locale/state if this fails.
      try {
        await ref.read(authProvider.notifier).refreshUserStatus();
      } catch (_) {
        // ignore refresh errors - they should not revert user's language choice
      }
    } catch (e) {
      state = state.copyWith(
        persistedCode: previousCode,
        isSaving: false,
        error: () => e is AppError
            ? e
            : const DataAppError.updateFailed('language settings'),
      );
    }
  }
}
