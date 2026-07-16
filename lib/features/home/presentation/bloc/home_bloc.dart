import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../test/data/repositories/test_repository.dart';
import '../../../test/domain/entities/test_app.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required TestRepository testRepository})
      : _testRepository = testRepository,
        super(const HomeState()) {
    on<HomeTestsRequested>(_onTestsRequested);
    on<HomeTestsLoadMore>(_onLoadMore);
    on<_HomeLoaded>(_onLoaded);
    on<_HomeFailed>(_onFailed);
  }

  final TestRepository _testRepository;
  DateTime? _lastCreatedAt;
  bool _hasMore = true;

  Future<void> _onTestsRequested(
    HomeTestsRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    _lastCreatedAt = null;
    _hasMore = true;
    try {
      final tests = await _testRepository.getTests(limit: 20);
      _lastCreatedAt = tests.isEmpty ? null : tests.last.createdAt;
      _hasMore = tests.length >= 20;
      emit(state.copyWith(
        status: HomeStatus.loaded,
        tests: tests,
        hasMore: _hasMore,
      ));
    } catch (_) {
      emit(const HomeState(status: HomeStatus.error));
    }
  }

  Future<void> _onLoadMore(
    HomeTestsLoadMore event,
    Emitter<HomeState> emit,
  ) async {
    if (!_hasMore || _lastCreatedAt == null) return;
    emit(state.copyWith(status: HomeStatus.loadingMore));
    try {
      final tests = await _testRepository.getTests(
        limit: 20,
        before: _lastCreatedAt,
      );
      _hasMore = tests.length >= 20;
      if (tests.isNotEmpty) {
        _lastCreatedAt = tests.last.createdAt;
      }
      emit(state.copyWith(
        status: HomeStatus.loaded,
        tests: [...state.tests, ...tests],
        hasMore: _hasMore,
      ));
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.loaded));
    }
  }

  void _onLoaded(_HomeLoaded event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.loaded, tests: event.tests));
  }

  void _onFailed(_HomeFailed event, Emitter<HomeState> emit) {
    emit(const HomeState(status: HomeStatus.error));
  }
}
