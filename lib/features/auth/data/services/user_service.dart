import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Service Firestore pour la collection `users`.
class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Crée le document utilisateur seulement s'il n'existe pas encore.
  Future<void> createUserIfMissing(UserModel user) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set(user.toMap());
    }
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromSnapshot(doc);
  }

  /// Écoute en temps réel le document utilisateur.
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromSnapshot(doc) : null,
        );
  }

  Future<void> updateJoinedGroup(String uid, bool joined) async {
    await _users.doc(uid).update({'joinedGroup': joined});
  }

  Future<void> updateTesterEmail(String uid, String email) async {
    await _users.doc(uid).update({'testerEmail': email});
  }

  Future<void> updatePlayStoreConfigured(String uid) async {
    await _users.doc(uid).update({'playStoreConfigured': true});
  }

  Future<void> addPointsForReward(String uid, {required int points}) async {
    await _users.doc(uid).update({
      'points': FieldValue.increment(points),
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> updateRole(String uid, {required String role}) async {
    await _users.doc(uid).update({'role': role});
  }

  Future<void> deductPoints(String uid, {required int points}) async {
    await _users.doc(uid).update({
      'points': FieldValue.increment(-points),
    });
  }

  /// Incrémente les points et le nombre de tests réalisés.
  Future<void> addRewards(String uid, {required int points}) async {
    await _users.doc(uid).update({
      'points': FieldValue.increment(points),
      'testsDone': FieldValue.increment(1),
    });
  }
}
