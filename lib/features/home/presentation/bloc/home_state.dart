part of 'home_bloc.dart';

enum HomeStatus { loading, loaded, error, loadingMore }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.tests = const [],
    this.hasMore = true,
  });

  final HomeStatus status;
  final List<TestApp> tests;
  final bool hasMore;

  HomeState copyWith({
    HomeStatus? status,
    List<TestApp>? tests,
    bool? hasMore,
  }) {
    return HomeState(
      status: status ?? this.status,
      tests: tests ?? this.tests,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [status, tests, hasMore];
}
