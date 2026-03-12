import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_plan_app/features/shared/entities/legal_content.dart';
import 'legal_datasource.dart';

class SupabaseLegalDatasource implements LegalDatasource {
  final SupabaseClient _supabaseClient;

  SupabaseLegalDatasource(this._supabaseClient);

  @override
  Future<LegalContent?> getLegalContent(String name, String language) async {
    try {
      final response = await _supabaseClient
          .from('configurations')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (response == null) return null;

      // La info viene dentro de una columna llamada 'configuration'
      final configuration = response['configuration'] as Map<String, dynamic>?;
      if (configuration == null) return null;

      // Intentar obtener el idioma solicitado, fallback a 'en' si no existe
      var data = configuration[language] as Map<String, dynamic>?;
      if (data == null && language != 'en') {
        data = configuration['en'] as Map<String, dynamic>?;
      }

      if (data == null) return null;

      return LegalContent.fromJson(data);
    } catch (e) {
      print('DEBUG: Error in SupabaseLegalDatasource: $e');
      rethrow;
    }
  }
}
