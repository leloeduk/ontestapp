part of 'rewards_bloc.dart';

enum RewardsStatus { loading, loaded, error }

class RewardsState extends Equatable {
  const RewardsState({
    this.status = RewardsStatus.loading,
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
