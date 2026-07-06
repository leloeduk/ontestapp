part of 'feedback_bloc.dart';

enum FeedbackStatus { idle, submitting, success, error }

class FeedbackState extends Equatable {
  const FeedbackState({
    this.status = FeedbackStatus.idle,
    this.errorMessage,
  });

  final FeedbackStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
