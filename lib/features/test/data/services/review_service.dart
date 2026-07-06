import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/review_model.dart';

class ReviewService {
  ReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(AppConstants.reviewsCollection);

  Future<void> addReview(ReviewModel review) async {
    await _reviews.add(review.toMap());
  }

  Future<bool> hasReviewed(String userId, String testId) async {
    final query = await _reviews
        .where('userId', isEqualTo: userId)
        .where('testId', isEqualTo: testId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId, {int limit = 20}) async {
    final query = await _reviews
        .where('userId', isEqualTo: userId)
        .limit(limit)
        .get();
    final reviews = query.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
    reviews.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
    return reviews;
  }

  Future<List<ReviewModel>> getUnvalidatedReviews() async {
    final query = await _reviews
        .where('testValidated', isEqualTo: false)
        .get();
    final reviews = query.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList();
    reviews.sort((a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime(0)) ?? 0);
    return reviews;
  }

  Future<void> validateReview(String reviewId, int rewardPoints) async {
    await _reviews.doc(reviewId).update({
      'testValidated': true,
      'rewardPoints': rewardPoints,
    });
  }
}
