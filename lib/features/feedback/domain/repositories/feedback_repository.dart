import 'package:meal_plan_app/features/feedback/domain/entities/submit_feedback_request.dart';

abstract class FeedbackRepository {
  Future<void> submitFeedback(SubmitFeedbackRequest request);
}
