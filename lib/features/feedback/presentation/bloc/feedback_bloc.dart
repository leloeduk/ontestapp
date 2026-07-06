import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/feedback_service.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc({required FeedbackService feedbackService})
      : _feedbackService = feedbackService,
        super(const FeedbackState()) {
    on<FeedbackSubmitted>(_onSubmitted);
  }

  final FeedbackService _feedbackService;

  Future<void> _onSubmitted(
    FeedbackSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(const FeedbackState(status: FeedbackStatus.submitting));
    try {
      await _feedbackService.submitFeedback(
        userId: event.userId,
        userName: event.userName,
        userEmail: event.userEmail,
        message: event.message,
      );
      emit(const FeedbackState(status: FeedbackStatus.success));
    } catch (_) {
      emit(const FeedbackState(
        status: FeedbackStatus.error,
        errorMessage: 'Erreur lors de l\'envoi',
      ));
    }
  }
}
