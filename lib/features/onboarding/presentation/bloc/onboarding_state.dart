part of 'onboarding_bloc.dart';

enum OnboardingStatus { unknown, notSeen, seen }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.unknown,
    this.currentPage = 0,
  });

  final OnboardingStatus status;
  final int currentPage;

  OnboardingState copyWith({OnboardingStatus? status, int? currentPage}) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, currentPage];
}
