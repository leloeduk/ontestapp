part of 'home_bloc.dart';

enum HomeStatus { loading, loaded, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.tests = const [],
  });

  final HomeStatus status;
  final List<TestApp> tests;

  @override
  List<Object?> get props => [status, tests];
}
