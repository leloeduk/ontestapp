import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/test_repository.dart';

sealed class EditTestEvent extends Equatable {
  const EditTestEvent();

  @override
  List<Object?> get props => [];
}

class EditTestSubmitted extends EditTestEvent {
  const EditTestSubmitted({
    required this.testId,
    required this.title,
    required this.description,
    required this.category,
  });

  final String testId;
  final String title;
  final String description;
  final String category;

  @override
  List<Object?> get props => [testId, title, description, category];
}

class DeleteTestRequested extends EditTestEvent {
  const DeleteTestRequested(this.testId);

  final String testId;

  @override
  List<Object?> get props => [testId];
}

enum EditTestStatus { idle, submitting, success, error }

class EditTestState extends Equatable {
  const EditTestState({
    this.status = EditTestStatus.idle,
    this.errorMessage,
  });

  final EditTestStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}

class EditTestBloc extends Bloc<EditTestEvent, EditTestState> {
  EditTestBloc({required TestRepository testRepository})
      : _testRepository = testRepository,
        super(const EditTestState()) {
    on<EditTestSubmitted>(_onEdit);
    on<DeleteTestRequested>(_onDelete);
  }

  final TestRepository _testRepository;

  Future<void> _onEdit(
    EditTestSubmitted event,
    Emitter<EditTestState> emit,
  ) async {
    emit(const EditTestState(status: EditTestStatus.submitting));
    try {
      await _testRepository.updateTest(event.testId, {
        'title': event.title,
        'description': event.description,
        'category': event.category,
      });
      emit(const EditTestState(status: EditTestStatus.success));
    } catch (_) {
      emit(const EditTestState(
        status: EditTestStatus.error,
        errorMessage: 'Impossible de modifier',
      ));
    }
  }

  Future<void> _onDelete(
    DeleteTestRequested event,
    Emitter<EditTestState> emit,
  ) async {
    emit(const EditTestState(status: EditTestStatus.submitting));
    try {
      await _testRepository.deleteTest(event.testId);
      emit(const EditTestState(status: EditTestStatus.success));
    } catch (_) {
      emit(const EditTestState(
        status: EditTestStatus.error,
        errorMessage: 'Impossible de supprimer',
      ));
    }
  }
}
