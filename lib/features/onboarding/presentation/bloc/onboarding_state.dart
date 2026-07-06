part of 'onboarding_bloc.dart';

enum OnboardingStatus { unknown, notSeen, seen }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.unknown,
    this.currentPage = 0,
    this.termsAccepted = false,
  });

  final OnboardingStatus status;
  final int currentPage;
  final bool termsAccepted;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentPage,
    bool? termsAccepted,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [status, currentPage, termsAccepted];
}
