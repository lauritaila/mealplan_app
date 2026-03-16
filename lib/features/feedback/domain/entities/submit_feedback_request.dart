class SubmitFeedbackRequest {
  final String type; // 'bug' | 'suggestion' | 'general' | 'content'
  final String message;
  final String? context;
  final String? rating;

  SubmitFeedbackRequest({
    required this.type,
    required this.message,
    this.context,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      if (context != null) 'context': context,
      if (rating != null) 'rating': rating,
    };
  }
}
