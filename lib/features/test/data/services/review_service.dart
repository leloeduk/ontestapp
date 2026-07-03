import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/review_model.dart';

/// Service Firestore pour la collection `reviews`.
class ReviewService {
  ReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(AppConstants.reviewsCollection);

  Future<void> addReview(ReviewModel review) async {
    await _reviews.add(review.toMap());
  }

  /// Indique si l'utilisateur a déjà donné son avis sur ce test.
  Future<bool> hasReviewed(String userId, String testId) async {
    final query = await _reviews
        .where('userId', isEqualTo: userId)
        .where('testId', isEqualTo: testId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}
