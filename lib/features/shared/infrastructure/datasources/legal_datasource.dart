import 'package:meal_plan_app/features/shared/entities/legal_content.dart';

abstract class LegalDatasource {
  Future<LegalContent?> getLegalContent(String name, String language);
}
