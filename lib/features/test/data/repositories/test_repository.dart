import '../../domain/entities/test_app.dart';
import '../services/test_service.dart';

/// Abstraction des applications à tester pour les Blocs.
class TestRepository {
  TestRepository({required TestService testService})
      : _testService = testService;

  final TestService _testService;

  Stream<List<TestApp>> watchTests() => _testService.watchTests();

  Future<TestApp?> getTest(String id) => _testService.getTest(id);
}
