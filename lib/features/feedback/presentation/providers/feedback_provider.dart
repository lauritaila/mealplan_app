import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_plan_app/features/shared/providers/dio_provider.dart';
import 'package:meal_plan_app/features/shared/providers/supabase_provider.dart';
import 'package:meal_plan_app/features/feedback/domain/domain.dart';
import 'package:meal_plan_app/features/feedback/infrastructure/infrastructure.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final datasource = SupabaseFeedbackDatasource(
    supabase: ref.watch(supabaseClientProvider),
    dio: ref.watch(dioProvider),
  );
  return FeedbackRepositoryImpl(datasource);
});

final feedbackSubmissionProvider = StateNotifierProvider<FeedbackSubmission, AsyncValue<void>>((ref) {
  return FeedbackSubmission(ref);
});

class FeedbackSubmission extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  FeedbackSubmission(this.ref) : super(const AsyncValue.data(null));

  Future<void> submit(SubmitFeedbackRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(feedbackRepositoryProvider).submitFeedback(request));
  }
}
