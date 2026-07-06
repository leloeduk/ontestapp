import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/services/user_service.dart';

part 'earn_event.dart';
part 'earn_state.dart';

class EarnBloc extends Bloc<EarnEvent, EarnState> {
  EarnBloc({required UserService userService})
      : _userService = userService,
        super(const EarnState()) {
    on<EarnRewardWatched>(_onRewardWatched);
  }

  final UserService _userService;

  Future<void> _onRewardWatched(
    EarnRewardWatched event,
    Emitter<EarnState> emit,
  ) async {
    emit(const EarnState(status: EarnStatus.submitting));
    try {
      await _userService.addPointsForReward(event.uid, points: 5);
      emit(const EarnState(status: EarnStatus.success));
    } catch (_) {
      emit(const EarnState(
        status: EarnStatus.error,
        errorMessage: 'Erreur lors de l\'ajout des points',
      ));
    }
  }
}
