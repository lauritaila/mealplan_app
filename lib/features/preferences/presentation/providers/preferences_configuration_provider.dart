import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/features/preferences/domain/domain.dart';
import 'package:meal_plan_app/features/preferences/presentation/providers/preferences_repository_provider.dart';

part 'preferences_configuration_provider.g.dart';

@riverpod
Future<PreferencesConfiguration> preferencesConfiguration(Ref ref) async {
  final repository = ref.watch(preferencesRepositoryProvider);
  return repository.fetchPreferencesConfiguration();
}
