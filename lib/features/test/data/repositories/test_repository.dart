import '../../domain/entities/test_app.dart';
import '../models/test_model.dart';
import '../services/test_service.dart';

class TestRepository {
  TestRepository({required TestService testService})
      : _testService = testService;

  final TestService _testService;

  Stream<List<TestApp>> watchTests() => _testService.watchTests();

  Future<TestApp?> getTest(String id) => _testService.getTest(id);

  Future<void> addTest(TestModel test) => _testService.addTest(test);
}
