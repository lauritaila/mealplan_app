import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/core/supabase/supabase_provider.dart';

part 'auth_state_changes_provider.g.dart';

@riverpod
Stream<dynamic> authStateChanges(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const Stream.empty();
  return client.auth.onAuthStateChange;
}
