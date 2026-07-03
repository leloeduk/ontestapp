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
        testId: event.testId,
        rating: event.rating,
        comment: event.comment,
        rewardPoints: event.rewardPoints,
      );
      emit(const ReviewState(status: ReviewStatus.success));
    } catch (_) {
      emit(const ReviewState(
        status: ReviewStatus.error,
        errorMessage: 'Impossible d\'enregistrer ton avis',
      ));
    }
  }
}
