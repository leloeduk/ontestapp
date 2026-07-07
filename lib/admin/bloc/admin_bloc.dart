import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/test/data/models/review_model.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminDashboardRequested extends AdminEvent {
  const AdminDashboardRequested();

  @override
  List<Object?> get props => [];
}

class AdminReviewsRequested extends AdminEvent {
  const AdminReviewsRequested();

  @override
  List<Object?> get props => [];
}

class AdminUsersRequested extends AdminEvent {
  const AdminUsersRequested();

  @override
  List<Object?> get props => [];
}

class AdminValidateReview extends AdminEvent {
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

class AdminDeleteReview extends AdminEvent {
  const AdminDeleteReview({
    required this.reviewId,
    required this.screenshot1Url,
    required this.screenshot2Url,
  });

  final String reviewId;
  final String screenshot1Url;
  final String screenshot2Url;

  @override
  List<Object?> get props => [reviewId, screenshot1Url, screenshot2Url];
}

enum AdminStatus { idle, loading, loaded, error }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.idle,
    this.stats = const {},
    this.reviews = const [],
    this.users = const [],
    this.errorMessage,
  });

  final AdminStatus status;
  final Map<String, int> stats;
  final List<ReviewModel> reviews;
  final List<Map<String, dynamic>> users;
  final String? errorMessage;

  AdminState copyWith({
    AdminStatus? status,
    Map<String, int>? stats,
    List<ReviewModel>? reviews,
    List<Map<String, dynamic>>? users,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      reviews: reviews ?? this.reviews,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, reviews, users, errorMessage];
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        super(const AdminState()) {
    on<AdminDashboardRequested>(_onDashboardRequested);
    on<AdminReviewsRequested>(_onReviewsRequested);
    on<AdminUsersRequested>(_onUsersRequested);
    on<AdminValidateReview>(_onValidateReview);
    on<AdminDeleteReview>(_onDeleteReview);
  }

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  Future<void> _onDashboardRequested(
    AdminDashboardRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final usersSnap = await _users.get();
      final totalUsers = usersSnap.docs.length;
      final totalPoints = usersSnap.docs.fold<int>(
        0,
        (s, d) => s + ((d.data()['points'] ?? 0) as int),
      );

      final pendingSnap = await _reviews
          .where('testValidated', isEqualTo: false)
          .get();
      final pendingReviews = pendingSnap.docs.length;

      emit(state.copyWith(
        status: AdminStatus.loaded,
        stats: {
          'totalUsers': totalUsers,
          'totalPoints': totalPoints,
          'pendingReviews': pendingReviews,
        },
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: 'Impossible de charger les statistiques',
      ));
    }
  }

  Future<void> _onReviewsRequested(
    AdminReviewsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final snap = await _reviews
          .where('testValidated', isEqualTo: false)
          .get();
      final reviews = snap.docs
          .map((doc) => ReviewModel.fromSnapshot(doc))
          .toList();
      reviews.sort(
        (a, b) =>
            b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0,
      );

      emit(state.copyWith(
        status: AdminStatus.loaded,
        reviews: reviews,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: 'Impossible de charger les soumissions',
      ));
    }
  }

  Future<void> _onUsersRequested(
    AdminUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final snap = await _users.get();
      final users = snap.docs.map((d) {
        final data = d.data();
        return <String, dynamic>{
          'uid': d.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'points': data['points'] ?? 0,
          'testsDone': data['testsDone'] ?? 0,
          'plan': data['plan'] ?? 'free',
          'isAdmin': data['isAdmin'] ?? false,
        };
      }).toList();

      emit(state.copyWith(
        status: AdminStatus.loaded,
        users: users,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: 'Impossible de charger les utilisateurs',
      ));
    }
  }

  Future<void> _onValidateReview(
    AdminValidateReview event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _reviews.doc(event.reviewId).update({
        'testValidated': true,
        'rewardPoints': event.rewardPoints,
      });
      await _users.doc(event.userId).update({
        'points': FieldValue.increment(event.rewardPoints),
        'testsDone': FieldValue.increment(1),
      });
      add(const AdminReviewsRequested());
    } catch (_) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: 'Erreur lors de la validation',
      ));
    }
  }

  Future<void> _onDeleteReview(
    AdminDeleteReview event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await _storage.refFromURL(event.screenshot1Url).delete();
      await _storage.refFromURL(event.screenshot2Url).delete();
      await _reviews.doc(event.reviewId).delete();
      add(const AdminReviewsRequested());
    } catch (_) {
      emit(state.copyWith(
        status: AdminStatus.error,
        errorMessage: 'Erreur lors de la suppression',
      ));
    }
  }
}
