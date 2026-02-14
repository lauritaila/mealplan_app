import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/config/config.dart';
import 'package:meal_plan_app/features/auth/presentation/provider/provider.dart';
import 'profile_repository_provider.dart';

part 'language_settings_provider.g.dart';

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
    if (state.selectedCode == state.persistedCode) return;
    final authState = ref.read(authProvider);
    if (authState is! AuthenticatedAuthState) {
      state = state.copyWith(
        error: () => const PermissionAppError.unauthorized(),
      );
      return;
    }
    state = state.copyWith(isSaving: true, error: () => null);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateLanguage(state.selectedCode);
      await ref
          .read(appLocaleProvider.notifier)
          .setLanguageCode(state.selectedCode);
      await ref.read(authProvider.notifier).refreshUserStatus();
      state = state.copyWith(
        persistedCode: state.selectedCode,
        isSaving: false,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: () => e is AppError
            ? e
            : const DataAppError.updateFailed('language settings'),
      );
    }
  }
}
