import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/core/supabase/supabase_provider.dart';
import 'package:meal_plan_app/features/profile/infrastructure/infrastructure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_provider.g.dart';

@riverpod
ProfileRepositoryImpl profileRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is not initialized.');
  }
  return ProfileRepositoryImpl(ProfileDatasourceImpl(client));
}
