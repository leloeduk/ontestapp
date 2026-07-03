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
}
