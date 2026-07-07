import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/services/user_service.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

sealed class AdminValidationEvent extends Equatable {
  const AdminValidationEvent();

  @override
  List<Object?> get props => [];
}

class AdminValidationRequested extends AdminValidationEvent {
  const AdminValidationRequested();

  @override
  List<Object?> get props => [];
}

class AdminValidateReview extends AdminValidationEvent {
  const AdminValidateReview({
    required this.reviewId,
    required this.userId,
    required this.rewardPoints,
  });

  final String reviewId;
  final String userId;
  final int rewardPoints;

  @override
  List<Object?> get props => [reviewId, userId, rewardPoints];
}

enum AdminValidationStatus { idle, loading, loaded, validating, error }

class AdminValidationState extends Equatable {
  const AdminValidationState({
    this.status = AdminValidationStatus.idle,
    this.reviews = const [],
    this.userTestsCount = const {},
    this.errorMessage,
  });

  final AdminValidationStatus status;
  final List<ReviewModel> reviews;
  final Map<String, int> userTestsCount;
  final String? errorMessage;

  AdminValidationState copyWith({
    AdminValidationStatus? status,
    List<ReviewModel>? reviews,
    Map<String, int>? userTestsCount,
    String? errorMessage,
  }) {
    return AdminValidationState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      userTestsCount: userTestsCount ?? this.userTestsCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, userTestsCount, errorMessage];
}

class AdminValidationBloc
    extends Bloc<AdminValidationEvent, AdminValidationState> {
  AdminValidationBloc({
    required ReviewRepository reviewRepository,
    required UserService userService,
  })  : _reviewRepository = reviewRepository,
        _userService = userService,
        super(const AdminValidationState()) {
    on<AdminValidationRequested>(_onRequested);
    on<AdminValidateReview>(_onValidate);
  }

  final ReviewRepository _reviewRepository;
  final UserService _userService;

  Future<void> _onRequested(
    AdminValidationRequested event,
    Emitter<AdminValidationState> emit,
  ) async {
    emit(state.copyWith(status: AdminValidationStatus.loading));
    try {
      final reviews = await _reviewRepository.getUnvalidatedReviews();
      final userIds = reviews.map((r) => r.userId).toSet().toList();
      final users = await Future.wait(
        userIds.map((id) => _userService.getUser(id)),
      );
      final userTestsCount = <String, int>{};
      for (final u in users) {
        if (u != null) userTestsCount[u.uid] = u.testsDone;
      }
      emit(state.copyWith(
        status: AdminValidationStatus.loaded,
        reviews: reviews,
        userTestsCount: userTestsCount,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminValidationStatus.error,
        errorMessage: 'Impossible de charger les soumissions',
      ));
    }
  }

  Future<void> _onValidate(
    AdminValidateReview event,
    Emitter<AdminValidationState> emit,
  ) async {
    if (state.status == AdminValidationStatus.validating) return;
    emit(state.copyWith(status: AdminValidationStatus.validating));
    try {
      await _reviewRepository.validateReview(
        reviewId: event.reviewId,
        userId: event.userId,
        rewardPoints: event.rewardPoints,
      );
      final userIds =
          state.reviews.map((r) => r.userId).toSet().toList();
      final users = await Future.wait(
        userIds.map((id) => _userService.getUser(id)),
      );
      final userTestsCount = <String, int>{};
      for (final u in users) {
        if (u != null) userTestsCount[u.uid] = u.testsDone;
      }
      final reviews = await _reviewRepository.getUnvalidatedReviews();
      emit(state.copyWith(
        status: AdminValidationStatus.loaded,
        reviews: reviews,
        userTestsCount: userTestsCount,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminValidationStatus.error,
        errorMessage: 'Erreur lors de la validation',
      ));
    }
  }
}
