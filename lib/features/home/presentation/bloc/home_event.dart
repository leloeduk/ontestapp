part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTestsRequested extends HomeEvent {
  const HomeTestsRequested();
}

class HomeTestsLoadMore extends HomeEvent {
  const HomeTestsLoadMore();
}

class _HomeLoaded extends HomeEvent {
  const _HomeLoaded(this.tests);

  final List<TestApp> tests;

  @override
  List<Object?> get props => [tests];
}

class _HomeFailed extends HomeEvent {
  const _HomeFailed();
}
