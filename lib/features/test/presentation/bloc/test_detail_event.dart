part of 'test_detail_bloc.dart';

sealed class TestDetailEvent extends Equatable {
  const TestDetailEvent();

  @override
  List<Object?> get props => [];
}

class TestDetailRequested extends TestDetailEvent {
  const TestDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
