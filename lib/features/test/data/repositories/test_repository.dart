import '../../domain/entities/test_app.dart';
import '../models/test_model.dart';
import '../services/test_service.dart';

class TestRepository {
  TestRepository({required TestService testService})
      : _testService = testService;

  final TestService _testService;

  Future<List<TestApp>> getTests({int limit = 20, DateTime? before}) =>
      _testService.getTests(limit: limit, before: before);

  Future<List<TestApp>> getUserTests(String uid) =>
      _testService.getUserTests(uid);

  Future<TestApp?> getTest(String id) => _testService.getTest(id);

  Future<void> addTest(TestModel test) => _testService.addTest(test);

  Future<void> updateTest(String id, Map<String, dynamic> data) =>
      _testService.updateTest(id, data);

  Future<void> deleteTest(String id) => _testService.deleteTest(id);
}
