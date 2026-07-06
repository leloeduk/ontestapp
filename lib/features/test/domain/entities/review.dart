import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.userId,
    required this.testId,
    required this.screenshot1Url,
    required this.screenshot2Url,
    this.userName,
    this.testName,
    this.playStoreUrl,
    this.testValidated = false,
    this.rewardPoints = 0,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String testId;
  final String screenshot1Url;
  final String screenshot2Url;
  final String? userName;
  final String? testName;
  final String? playStoreUrl;
  final bool testValidated;
  final int rewardPoints;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        testId,
        screenshot1Url,
        screenshot2Url,
        userName,
        testName,
        playStoreUrl,
        testValidated,
        rewardPoints,
        createdAt,
      ];
}
