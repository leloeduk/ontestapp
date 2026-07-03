import 'dart:async';

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
    on<_HomeTestsUpdated>(_onTestsUpdated);
    on<_HomeFailed>(_onFailed);

    _sub = _testRepository.watchTests().listen(
          (tests) => add(_HomeTestsUpdated(tests)),
          onError: (_) => add(const _HomeFailed()),
        );
  }

  final TestRepository _testRepository;
  late final StreamSubscription<List<TestApp>> _sub;

  void _onTestsUpdated(_HomeTestsUpdated event, Emitter<HomeState> emit) {
    emit(HomeState(status: HomeStatus.loaded, tests: event.tests));
  }

  void _onFailed(_HomeFailed event, Emitter<HomeState> emit) {
    emit(const HomeState(status: HomeStatus.error));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
