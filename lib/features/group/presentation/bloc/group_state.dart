part of 'group_bloc.dart';

enum GroupStatus { idle, submitting, error }

class GroupState extends Equatable {
  const GroupState({this.status = GroupStatus.idle, this.errorMessage});

  final GroupStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
