part of 'test_detail_bloc.dart';

enum TestDetailStatus { loading, loaded, error }

class TestDetailState extends Equatable {
  const TestDetailState({
    this.status = TestDetailStatus.loading,
    this.test,
    this.errorMessage,
  });

  final TestDetailStatus status;
  final TestApp? test;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, test, errorMessage];
}
