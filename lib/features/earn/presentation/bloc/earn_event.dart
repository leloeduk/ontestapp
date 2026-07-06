part of 'earn_bloc.dart';

sealed class EarnEvent extends Equatable {
  const EarnEvent();

  @override
  List<Object?> get props => [];
}

class EarnRewardWatched extends EarnEvent {
  const EarnRewardWatched(this.uid);

  final String uid;

  @override
  List<Object?> get props => [uid];
}
