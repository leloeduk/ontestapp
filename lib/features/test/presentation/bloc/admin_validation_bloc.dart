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

class AdminToggleReview extends AdminValidationEvent {
  const AdminToggleReview(this.reviewId);

  final String reviewId;

  @override
  List<Object?> get props => [reviewId];
}

class AdminSelectAll extends AdminValidationEvent {
  const AdminSelectAll();

  @override
  List<Object?> get props => [];
}

class AdminDeselectAll extends AdminValidationEvent {
  const AdminDeselectAll();

  @override
  List<Object?> get props => [];
}

class AdminBatchValidate extends AdminValidationEvent {
  const AdminBatchValidate();

  @override
  List<Object?> get props => [];
}

class AdminBatchDelete extends AdminValidationEvent {
  const AdminBatchDelete();

  @override
  List<Object?> get props => [];
}

enum AdminValidationStatus { idle, loading, loaded, validating, error, deleting }

class AdminValidationState extends Equatable {
  const AdminValidationState({
    this.status = AdminValidationStatus.idle,
    this.reviews = const [],
    this.userTestsCount = const {},
    this.selectedIds = const {},
    this.errorMessage,
  });

  final AdminValidationStatus status;
  final List<ReviewModel> reviews;
  final Map<String, int> userTestsCount;
  final Set<String> selectedIds;
  final String? errorMessage;

  bool get allSelected => reviews.isNotEmpty && selectedIds.length == reviews.length;

  AdminValidationState copyWith({
    AdminValidationStatus? status,
    List<ReviewModel>? reviews,
    Map<String, int>? userTestsCount,
    Set<String>? selectedIds,
    String? errorMessage,
  }) {
    return AdminValidationState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      userTestsCount: userTestsCount ?? this.userTestsCount,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reviews, userTestsCount, selectedIds, errorMessage];
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
    on<AdminToggleReview>(_onToggle);
    on<AdminSelectAll>(_onSelectAll);
    on<AdminDeselectAll>(_onDeselectAll);
    on<AdminBatchValidate>(_onBatchValidate);
    on<AdminBatchDelete>(_onBatchDelete);
  }

  final ReviewRepository _reviewRepository;
  final UserService _userService;

  Future<void> _onRequested(
    AdminValidationRequested event,
    Emitter<AdminValidationState> emit,
  ) async {
    emit(state.copyWith(status: AdminValidationStatus.loading));
    try {
      final reviews = await _reviewRepository.getAllReviews();
      final userTestsCount = await _loadUserTestsCount(reviews);
      emit(state.copyWith(
        status: AdminValidationStatus.loaded,
        reviews: reviews,
        userTestsCount: userTestsCount,
        selectedIds: {},
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
      add(const AdminValidationRequested());
    } catch (_) {
      emit(state.copyWith(
        status: AdminValidationStatus.error,
        errorMessage: 'Erreur lors de la validation',
      ));
    }
  }

  void _onToggle(
    AdminToggleReview event,
    Emitter<AdminValidationState> emit,
  ) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(event.reviewId)) {
      selected.remove(event.reviewId);
    } else {
      selected.add(event.reviewId);
    }
    emit(state.copyWith(selectedIds: selected));
  }

  void _onSelectAll(
    AdminSelectAll event,
    Emitter<AdminValidationState> emit,
  ) {
    emit(state.copyWith(
      selectedIds: state.reviews.map((r) => r.id).toSet(),
    ));
  }

  void _onDeselectAll(
    AdminDeselectAll event,
    Emitter<AdminValidationState> emit,
  ) {
    emit(state.copyWith(selectedIds: {}));
  }

  Future<void> _onBatchValidate(
    AdminBatchValidate event,
    Emitter<AdminValidationState> emit,
  ) async {
    if (state.selectedIds.isEmpty) return;
    emit(state.copyWith(status: AdminValidationStatus.validating));
    try {
      for (final review in state.reviews) {
        if (state.selectedIds.contains(review.id)) {
          await _reviewRepository.validateReview(
            reviewId: review.id,
            userId: review.userId,
            rewardPoints: review.rewardPoints,
          );
        }
      }
      add(const AdminValidationRequested());
    } catch (_) {
      emit(state.copyWith(
        status: AdminValidationStatus.error,
        errorMessage: 'Erreur lors de la validation',
      ));
    }
  }

  Future<void> _onBatchDelete(
    AdminBatchDelete event,
    Emitter<AdminValidationState> emit,
  ) async {
    if (state.selectedIds.isEmpty) return;
    emit(state.copyWith(status: AdminValidationStatus.deleting));
    try {
      for (final review in state.reviews) {
        if (state.selectedIds.contains(review.id)) {
          await _reviewRepository.deleteReview(
            reviewId: review.id,
            screenshot1Url: review.screenshot1Url,
            screenshot2Url: review.screenshot2Url,
          );
        }
      }
      add(const AdminValidationRequested());
    } catch (_) {
      emit(state.copyWith(
        status: AdminValidationStatus.error,
        errorMessage: 'Erreur lors de la suppression',
      ));
    }
  }

  Future<Map<String, int>> _loadUserTestsCount(List<ReviewModel> reviews) async {
    final userIds = reviews.map((r) => r.userId).toSet().toList();
    final results = await Future.wait(
      userIds.map((id) => _userService.getUser(id).catchError((_) => null)),
    );
    final userTestsCount = <String, int>{};
    for (final u in results) {
      if (u != null) userTestsCount[u.uid] = u.testsDone;
    }
    return userTestsCount;
  }
}
