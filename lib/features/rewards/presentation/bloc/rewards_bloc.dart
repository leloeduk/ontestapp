import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../test/data/models/review_model.dart';
import '../../../test/data/repositories/review_repository.dart';

part 'rewards_event.dart';
part 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(const RewardsState()) {
    on<RewardsRequested>(_onRequested);
  }

  final ReviewRepository _reviewRepository;

  Future<void> _onRequested(
    RewardsRequested event,
    Emitter<RewardsState> emit,
  ) async {
    emit(const RewardsState(status: RewardsStatus.loading));
    try {
      final reviews = await _reviewRepository.getReviewsByUser(event.userId);
      final totalPoints =
          reviews.fold<int>(0, (sum, r) => sum + r.rewardPoints);
      emit(RewardsState(
        status: RewardsStatus.loaded,
        reviews: reviews,
        totalPoints: totalPoints,
      ));
    } catch (_) {
      emit(const RewardsState(
        status: RewardsStatus.error,
        errorMessage: 'Impossible de charger l\'historique',
      ));
    }
  }
}
