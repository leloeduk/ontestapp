import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/services/user_service.dart';
import '../../data/models/test_model.dart';
import '../../data/repositories/test_repository.dart';
import '../../data/services/storage_service.dart';

sealed class AddTestEvent extends Equatable {
  const AddTestEvent();

  @override
  List<Object?> get props => [];
}

class AddTestSubmitted extends AddTestEvent {
  const AddTestSubmitted({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.playStoreUrl,
    required this.category,
    required this.userId,
  });

  final String title;
  final String description;
  final String imagePath;
  final String playStoreUrl;
  final String category;
  final String userId;

  @override
  List<Object?> get props => [
        title,
        description,
        imagePath,
        playStoreUrl,
        category,
        userId,
      ];
}

enum AddTestStatus { idle, submitting, success, error }

class AddTestState extends Equatable {
  const AddTestState({
    this.status = AddTestStatus.idle,
    this.submitting = false,
    this.success = false,
    this.errorMessage,
  });

  final AddTestStatus status;
  final bool submitting;
  final bool success;
  final String? errorMessage;

  AddTestState copyWith({
    AddTestStatus? status,
    bool? submitting,
    bool? success,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddTestState(
      status: status ?? this.status,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, submitting, success, errorMessage];
}

class AddTestBloc extends Bloc<AddTestEvent, AddTestState> {
  AddTestBloc({
    required TestRepository testRepository,
    required UserService userService,
    required StorageService storageService,
  })  : _testRepository = testRepository,
        _userService = userService,
        _storageService = storageService,
        super(const AddTestState()) {
    on<AddTestSubmitted>(_onSubmitted);
  }

  final TestRepository _testRepository;
  final UserService _userService;
  final StorageService _storageService;

  Future<void> _onSubmitted(
    AddTestSubmitted event,
    Emitter<AddTestState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final userId = event.userId;
      final testId = _testRepository.generateId();

      final iconUrl = await _storageService.uploadTestIcon(
        testId: testId,
        filePath: event.imagePath,
      );

      final test = TestModel(
        id: testId,
        title: event.title,
        description: event.description,
        iconUrl: iconUrl,
        playStoreUrl: event.playStoreUrl,
        points: 10,
        category: event.category,
        steps: const [],
        userId: userId,
      );
      await _testRepository.addTest(test);
      await _userService.deductPoints(userId, points: 50);
      emit(const AddTestState(success: true));
    } catch (e) {
      final msg = e.toString().contains('permission-denied')
          ? 'Permission refusée : mets à jour les règles Firestore pour autoriser l\'écriture dans la collection "tests"'
          : 'Erreur : ${e.toString()}';
      emit(state.copyWith(
        status: AddTestStatus.error,
        submitting: false,
        errorMessage: msg,
      ));
    }
  }
}
