part of 'review_bloc.dart';

sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class ReviewSubmitted extends ReviewEvent {
  const ReviewSubmitted({
    required this.userId,
    required this.userName,
    required this.testId,
    required this.testName,
    required this.screenshot1Path,
    required this.screenshot2Path,
    required this.appName,
    this.playStoreUrl,
    this.rewardPoints = 10,
  });

  final String userId;
  final String userName;
  final String testId;
  final String testName;
  final String screenshot1Path;
  final String screenshot2Path;
  final String appName;
  final String? playStoreUrl;
  final int rewardPoints;

  @override
  List<Object?> get props => [
        userId,
        userName,
        testId,
        testName,
        screenshot1Path,
        screenshot2Path,
        appName,
        playStoreUrl,
        rewardPoints,
      ];
}
