import 'package:equatable/equatable.dart';

/// Avis laissé par un utilisateur sur une application testée.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.userId,
    required this.testId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String testId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, userId, testId, rating, comment, createdAt];
}
