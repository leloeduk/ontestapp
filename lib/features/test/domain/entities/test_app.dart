import 'package:equatable/equatable.dart';

/// Application à tester.
class TestApp extends Equatable {
  const TestApp({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.playStoreUrl,
    required this.points,
    this.steps = const [],
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String playStoreUrl;
  final int points;
  final List<String> steps;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconUrl,
        playStoreUrl,
        points,
        steps,
        createdAt,
      ];
}
