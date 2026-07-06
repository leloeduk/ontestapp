import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/review_repository.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(const ReviewState()) {
    on<ReviewSubmitted>(_onSubmitted);
  }

  final ReviewRepository _reviewRepository;

  Future<void> _onSubmitted(
    ReviewSubmitted event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewState(status: ReviewStatus.submitting));
    try {
      await _reviewRepository.submitReview(
        userId: event.userId,
        userName: event.userName,
        testId: event.testId,
        testName: event.testName,
        screenshot1Path: event.screenshot1Path,
        screenshot2Path: event.screenshot2Path,
        appName: event.appName,
        rewardPoints: event.rewardPoints,
      );
      emit(const ReviewState(status: ReviewStatus.success));
    } catch (e) {
      emit(ReviewState(
        status: ReviewStatus.error,
        errorMessage: e.toString().contains('déjà donné')
            ? 'Tu as déjà donné ton avis sur cette application'
            : 'Impossible d\'enregistrer ton avis',
      ));
    }
  }
}
