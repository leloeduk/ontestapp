import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submitFeedback({
    required String userId,
    required String userName,
    required String userEmail,
    required String message,
  }) async {
    await _firestore.collection('feedback').add({
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
