import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ontestapp/features/test/data/repositories/review_repository.dart';
import 'package:ontestapp/features/test/presentation/bloc/review_bloc.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository repository;

  setUp(() => repository = MockReviewRepository());

  const event = ReviewSubmitted(
    userId: 'u1',
    userName: 'Test User',
    testId: 't1',
    testName: 'Test App',
    screenshot1Path: '/path/1.jpg',
    screenshot2Path: '/path/2.jpg',
    appName: 'Test App',
  );

  blocTest<ReviewBloc, ReviewState>(
    'émet [submitting, success] quand la soumission réussit',
    setUp: () {
      when(() => repository.submitReview(
            userId: any(named: 'userId'),
            userName: any(named: 'userName'),
            testId: any(named: 'testId'),
            testName: any(named: 'testName'),
            screenshot1Path: any(named: 'screenshot1Path'),
            screenshot2Path: any(named: 'screenshot2Path'),
            appName: any(named: 'appName'),
            rewardPoints: any(named: 'rewardPoints'),
          )).thenAnswer((_) async {});
    },
    build: () => ReviewBloc(reviewRepository: repository),
    act: (bloc) => bloc.add(event),
    expect: () => [
      isA<ReviewState>()
          .having((s) => s.status, 'status', ReviewStatus.submitting),
      isA<ReviewState>()
          .having((s) => s.status, 'status', ReviewStatus.success),
    ],
  );

  blocTest<ReviewBloc, ReviewState>(
    'émet [submitting, error] quand la soumission échoue',
    setUp: () {
      when(() => repository.submitReview(
            userId: any(named: 'userId'),
            userName: any(named: 'userName'),
            testId: any(named: 'testId'),
            testName: any(named: 'testName'),
            screenshot1Path: any(named: 'screenshot1Path'),
            screenshot2Path: any(named: 'screenshot2Path'),
            appName: any(named: 'appName'),
            rewardPoints: any(named: 'rewardPoints'),
          )).thenThrow(Exception('boom'));
    },
    build: () => ReviewBloc(reviewRepository: repository),
    act: (bloc) => bloc.add(event),
    expect: () => [
      isA<ReviewState>()
          .having((s) => s.status, 'status', ReviewStatus.submitting),
      isA<ReviewState>()
          .having((s) => s.status, 'status', ReviewStatus.error),
    ],
  );
}
