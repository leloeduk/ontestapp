import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/test_model.dart';

/// Service Firestore pour la collection `tests`.
class TestService {
  TestService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tests =>
      _firestore.collection(AppConstants.testsCollection);

  Stream<List<TestModel>> watchTests() {
    return _tests.orderBy('createdAt', descending: true).snapshots().map(
          (query) =>
              query.docs.map((doc) => TestModel.fromSnapshot(doc)).toList(),
        );
  }

  Future<TestModel?> getTest(String id) async {
    final doc = await _tests.doc(id).get();
    if (!doc.exists) return null;
    return TestModel.fromSnapshot(doc);
  }

  Future<void> addTest(TestModel test) async {
    final doc = _tests.doc();
    final model = TestModel(
      id: doc.id,
      title: test.title,
      description: test.description,
      iconUrl: test.iconUrl,
      playStoreUrl: test.playStoreUrl,
      points: test.points,
      category: test.category,
      steps: test.steps,
    );
    await doc.set(model.toMap());
  }
}
