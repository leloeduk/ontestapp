part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class GroupJoinRequested extends GroupEvent {
  const GroupJoinRequested({
    required this.uid,
    this.testerEmail,
    this.playStoreConfigured = false,
    this.isDeveloper = false,
  });

  final String uid;
  final String? testerEmail;
  final bool playStoreConfigured;
  final bool isDeveloper;

  @override
  List<Object?> get props => [uid, testerEmail, playStoreConfigured, isDeveloper];
}
