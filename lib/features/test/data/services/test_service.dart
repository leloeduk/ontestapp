import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/test_model.dart';

class TestService {
  TestService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tests =>
      _firestore.collection(AppConstants.testsCollection);

  Future<List<TestModel>> getTests({
    int limit = 20,
    DateTime? before,
  }) async {
    var query =
        _tests.orderBy('createdAt', descending: true).limit(limit);
    if (before != null) {
      query = query.where('createdAt', isLessThan: before);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => TestModel.fromSnapshot(doc)).toList();
  }

  Future<List<TestModel>> getUserTests(String uid) async {
    final snap = await _tests
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((doc) => TestModel.fromSnapshot(doc)).toList();
  }

  Future<TestModel?> getTest(String id) async {
    final doc = await _tests.doc(id).get();
    if (!doc.exists) return null;
    return TestModel.fromSnapshot(doc);
  }

  String generateId() => _tests.doc().id;

  Future<void> addTest(TestModel test) async {
    final doc = _tests.doc(test.id);
    final model = TestModel(
      id: doc.id,
      title: test.title,
      description: test.description,
      iconUrl: test.iconUrl,
      playStoreUrl: test.playStoreUrl,
      points: test.points,
      category: test.category,
      steps: test.steps,
      userId: test.userId,
    );
    await doc.set(model.toMap());
  }

  Future<void> updateTest(String id, Map<String, dynamic> data) async {
    await _tests.doc(id).update(data);
  }

  Future<void> deleteTest(String id) async {
    await _tests.doc(id).delete();
  }
}
