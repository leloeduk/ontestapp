import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

/// Modèle Firestore <-> [Review].
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.testId,
    required super.rating,
    required super.comment,
    super.rewardPoints,
    super.createdAt,
  });

  factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const {};
    final createdAt = map['createdAt'];
    return ReviewModel(
      id: doc.id,
      userId: (map['userId'] ?? '') as String,
      testId: (map['testId'] ?? '') as String,
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      comment: (map['comment'] ?? '') as String,
      rewardPoints: (map['rewardPoints'] ?? 0) as int,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testId': testId,
      'rating': rating,
      'comment': comment,
      'rewardPoints': rewardPoints,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
