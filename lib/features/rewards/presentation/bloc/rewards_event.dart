part of 'rewards_bloc.dart';

sealed class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object?> get props => [];
}

class RewardsRequested extends RewardsEvent {
  const RewardsRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
