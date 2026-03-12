import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_plan_app/core/supabase/supabase_provider.dart';
import 'package:meal_plan_app/features/shared/domain/repositories/legal_repository.dart';
import 'package:meal_plan_app/features/shared/infrastructure/datasources/supabase_legal_datasource.dart';
import 'package:meal_plan_app/features/shared/infrastructure/repositories/legal_repository_impl.dart';
import 'package:meal_plan_app/features/shared/entities/legal_content.dart';

part 'legal_provider.g.dart';

@riverpod
LegalRepository legalRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase == null) throw Exception('Supabase client not initialized');
  final datasource = SupabaseLegalDatasource(supabase);
  return LegalRepositoryImpl(datasource);
}

@riverpod
Future<LegalContent?> getLegalContent(Ref ref, {required String configName, required String language}) {
  return ref.watch(legalRepositoryProvider).getLegalContent(configName, language);
}
