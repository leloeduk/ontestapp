part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class GroupJoinRequested extends GroupEvent {
  const GroupJoinRequested(this.uid);

  final String uid;

  @override
  List<Object?> get props => [uid];
}
