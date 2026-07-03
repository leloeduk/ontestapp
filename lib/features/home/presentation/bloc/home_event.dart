part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class _HomeTestsUpdated extends HomeEvent {
  const _HomeTestsUpdated(this.tests);

  final List<TestApp> tests;

  @override
  List<Object?> get props => [tests];
}

class _HomeFailed extends HomeEvent {
  const _HomeFailed();
}
