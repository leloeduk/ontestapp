part of 'earn_bloc.dart';

enum EarnStatus { idle, submitting, success, error }

class EarnState extends Equatable {
  const EarnState({
    this.status = EarnStatus.idle,
    this.errorMessage,
  });

  final EarnStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
