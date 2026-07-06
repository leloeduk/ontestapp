import '../../../auth/data/services/user_service.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/storage_service.dart';

class ReviewRepository {
  ReviewRepository({
    required ReviewService reviewService,
    required UserService userService,
    required StorageService storageService,
  })  : _reviewService = reviewService,
        _userService = userService,
        _storageService = storageService;

  final ReviewService _reviewService;
  final UserService _userService;
  final StorageService _storageService;

  Future<bool> hasReviewed(String userId, String testId) {
    return _reviewService.hasReviewed(userId, testId);
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) {
    return _reviewService.getReviewsByUser(userId);
  }

  Future<List<ReviewModel>> getUnvalidatedReviews() {
    return _reviewService.getUnvalidatedReviews();
  }

  Future<void> submitReview({
    required String userId,
    required String userName,
    required String testId,
    required String testName,
    required String screenshot1Path,
    required String screenshot2Path,
    required String appName,
    int rewardPoints = 10,
  }) async {
    final already = await _reviewService.hasReviewed(userId, testId);
    if (already) {
      throw Exception('Tu as déjà donné ton avis sur cette application');
    }

    final screenshot1Url = await _storageService.uploadScreenshot(
      userName: userName,
      testId: testId,
      appName: appName,
      filePath: screenshot1Path,
      captureNumber: 1,
    );
    final screenshot2Url = await _storageService.uploadScreenshot(
      userName: userName,
      testId: testId,
      appName: appName,
      filePath: screenshot2Path,
      captureNumber: 2,
    );

    final review = ReviewModel(
      id: '',
      userId: userId,
      userName: userName,
      testId: testId,
      testName: testName,
      screenshot1Url: screenshot1Url,
      screenshot2Url: screenshot2Url,
      rewardPoints: rewardPoints,
    );
    await _reviewService.addReview(review);
  }

  Future<void> validateReview({
    required String reviewId,
    required String userId,
    required int rewardPoints,
  }) async {
    await _reviewService.validateReview(reviewId, rewardPoints);
    await _userService.addRewards(userId, points: rewardPoints);
  }
}
