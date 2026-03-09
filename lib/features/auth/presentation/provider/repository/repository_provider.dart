import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/auth/infrastructure/infrastructure.dart';
import 'package:meal_plan_app/core/supabase/supabase_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'repository_provider.g.dart';

@riverpod
AuthRepositoryImpl authRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    throw StateError('Supabase client is not initialized.');
  }
  return AuthRepositoryImpl(AuthSupabaseDatasourceImpl(client));
}
