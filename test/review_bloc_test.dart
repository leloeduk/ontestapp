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
    testId: 't1',
    rating: 5,
    comment: 'Super',
    rewardPoints: 10,
  );

  blocTest<ReviewBloc, ReviewState>(
    'émet [submitting, success] quand la soumission réussit',
    setUp: () {
      when(() => repository.submitReview(
            userId: any(named: 'userId'),
            testId: any(named: 'testId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
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
            testId: any(named: 'testId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
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
