import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.testId,
    required super.screenshot1Url,
    required super.screenshot2Url,
    super.userName,
    super.testName,
    super.playStoreUrl,
    super.testValidated,
    super.rewardPoints,
    super.createdAt,
  });

  factory ReviewModel.fromSnapshot(DocumentSnapshot<Object?> doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? const {};
    final createdAt = map['createdAt'];
    return ReviewModel(
      id: doc.id,
      userId: (map['userId'] ?? '') as String,
      testId: (map['testId'] ?? '') as String,
      screenshot1Url: (map['screenshot1Url'] ?? '') as String,
      screenshot2Url: (map['screenshot2Url'] ?? '') as String,
      userName: map['userName'] as String?,
      testName: map['testName'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      testValidated: (map['testValidated'] ?? false) as bool,
      rewardPoints: (map['rewardPoints'] ?? 0) as int,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testId': testId,
      'screenshot1Url': screenshot1Url,
      'screenshot2Url': screenshot2Url,
      'userName': userName,
      'testName': testName,
      'playStoreUrl': playStoreUrl,
      'testValidated': testValidated,
      'rewardPoints': rewardPoints,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
