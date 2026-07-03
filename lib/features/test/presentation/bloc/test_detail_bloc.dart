import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/test_repository.dart';
import '../../domain/entities/test_app.dart';

part 'test_detail_event.dart';
part 'test_detail_state.dart';

class TestDetailBloc extends Bloc<TestDetailEvent, TestDetailState> {
  TestDetailBloc({required TestRepository testRepository})
      : _testRepository = testRepository,
        super(const TestDetailState()) {
    on<TestDetailRequested>(_onRequested);
  }

  final TestRepository _testRepository;

  Future<void> _onRequested(
    TestDetailRequested event,
    Emitter<TestDetailState> emit,
  ) async {
    emit(const TestDetailState(status: TestDetailStatus.loading));
    try {
      final test = await _testRepository.getTest(event.id);
      if (test == null) {
        emit(const TestDetailState(
          status: TestDetailStatus.error,
          errorMessage: 'Application introuvable',
        ));
      } else {
        emit(TestDetailState(status: TestDetailStatus.loaded, test: test));
      }
    } catch (_) {
      emit(const TestDetailState(
        status: TestDetailStatus.error,
        errorMessage: 'Erreur de chargement',
      ));
    }
  }
}
