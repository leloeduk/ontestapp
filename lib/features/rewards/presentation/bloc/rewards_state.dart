part of 'rewards_bloc.dart';

enum RewardsStatus { idle, loading, loaded, error }

class RewardsState extends Equatable {
  const RewardsState({
    this.status = RewardsStatus.idle,
    this.reviews = const [],
    this.totalPoints = 0,
    this.errorMessage,
  });

  final RewardsStatus status;
  final List<ReviewModel> reviews;
  final int totalPoints;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, reviews, totalPoints, errorMessage];
}
