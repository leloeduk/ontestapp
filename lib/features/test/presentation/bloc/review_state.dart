part of 'review_bloc.dart';

enum ReviewStatus { idle, submitting, success, error }

class ReviewState extends Equatable {
  const ReviewState({this.status = ReviewStatus.idle, this.errorMessage});

  final ReviewStatus status;
  final String? errorMessage;

  ReviewState copyWith({ReviewStatus? status, String? errorMessage}) {
    return ReviewState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
