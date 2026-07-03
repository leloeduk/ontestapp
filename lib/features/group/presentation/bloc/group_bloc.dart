import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/repositories/auth_repository.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const GroupState()) {
    on<GroupJoinRequested>(_onJoinRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onJoinRequested(
    GroupJoinRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupState(status: GroupStatus.submitting));
    try {
      await _authRepository.joinGroup(event.uid);
      emit(const GroupState(status: GroupStatus.success));
    } catch (_) {
      emit(const GroupState(
        status: GroupStatus.error,
        errorMessage: 'Impossible de valider. Réessaie.',
      ));
    }
  }
}
