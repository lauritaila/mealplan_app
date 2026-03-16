import 'package:meal_plan_app/features/feedback/domain/datasources/feedback_datasource.dart';
import 'package:meal_plan_app/features/feedback/domain/entities/submit_feedback_request.dart';
import 'package:meal_plan_app/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackDatasource _datasource;

  FeedbackRepositoryImpl(this._datasource);

  @override
  Future<void> submitFeedback(SubmitFeedbackRequest request) {
    return _datasource.submitFeedback(request);
  }
}
