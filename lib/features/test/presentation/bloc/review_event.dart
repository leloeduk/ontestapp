part of 'review_bloc.dart';

sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class ReviewSubmitted extends ReviewEvent {
  const ReviewSubmitted({
    required this.userId,
    required this.testId,
    required this.rating,
    required this.comment,
    required this.rewardPoints,
  });

  final String userId;
  final String testId;
  final double rating;
  final String comment;
  final int rewardPoints;

  @override
  List<Object?> get props => [userId, testId, rating, comment, rewardPoints];
}
