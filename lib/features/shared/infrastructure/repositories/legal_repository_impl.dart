import 'package:meal_plan_app/features/shared/entities/legal_content.dart';
import 'package:meal_plan_app/features/shared/domain/repositories/legal_repository.dart';
import 'package:meal_plan_app/features/shared/infrastructure/datasources/legal_datasource.dart';

class LegalRepositoryImpl implements LegalRepository {
  final LegalDatasource _datasource;

  LegalRepositoryImpl(this._datasource);

  @override
  Future<LegalContent?> getLegalContent(String name, String language) {
    return _datasource.getLegalContent(name, language);
  }
}
