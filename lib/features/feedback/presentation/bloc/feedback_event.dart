part of 'feedback_bloc.dart';

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

class FeedbackSubmitted extends FeedbackEvent {
  const FeedbackSubmitted({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.message,
  });

  final String userId;
  final String userName;
  final String userEmail;
  final String message;

  @override
  List<Object?> get props => [userId, userName, userEmail, message];
}
