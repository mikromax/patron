// lib/models/patron_feedback_request_dto.dart

// C#'taki QueryFeedbackStatus enum'ına karşılık gelen enum
enum QueryFeedbackStatus {
  None, // Genellikle 0
  Positive, // 1
  Negative, // 2
}

class PatronFeedbackRequestDto {
  final String queryLogId;
  final QueryFeedbackStatus feedbackStatus;
  final String? comment;

  PatronFeedbackRequestDto({
    required this.queryLogId,
    required this.feedbackStatus,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'QueryLogId': queryLogId,
      // Enum'ı C#'ın beklediği integer değere çeviriyoruz
      'FeedbackStatus': feedbackStatus.index,
      'Comment': comment,
    };
  }
}