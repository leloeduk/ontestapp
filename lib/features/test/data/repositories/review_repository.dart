import '../../../auth/data/services/user_service.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

/// Gère la soumission d'un avis et la récompense associée.
class ReviewRepository {
  ReviewRepository({
    required ReviewService reviewService,
    required UserService userService,
  })  : _reviewService = reviewService,
        _userService = userService;

  final ReviewService _reviewService;
  final UserService _userService;

  Future<bool> hasReviewed(String userId, String testId) {
    return _reviewService.hasReviewed(userId, testId);
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) {
    return _reviewService.getReviewsByUser(userId);
  }

  /// Enregistre l'avis puis crédite les points de l'utilisateur.
  Future<void> submitReview({
    required String userId,
    required String testId,
    required double rating,
    required String comment,
    required int rewardPoints,
  }) async {
    final already = await _reviewService.hasReviewed(userId, testId);
    if (already) {
      throw Exception('Tu as déjà donné ton avis sur cette application');
    }
    final review = ReviewModel(
      id: '',
      userId: userId,
      testId: testId,
      rating: rating,
      comment: comment,
      rewardPoints: rewardPoints,
    );
    await _reviewService.addReview(review);
    await _userService.addRewards(userId, points: rewardPoints);
  }
}
