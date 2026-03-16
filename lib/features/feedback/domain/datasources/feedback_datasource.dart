import 'package:meal_plan_app/features/feedback/domain/entities/submit_feedback_request.dart';

abstract class FeedbackDatasource {
  Future<void> submitFeedback(SubmitFeedbackRequest request);
}
