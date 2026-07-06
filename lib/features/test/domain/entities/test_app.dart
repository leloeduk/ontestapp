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
    this.category = '',
    this.steps = const [],
    this.createdAt,
    this.userId = '',
  });

  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String playStoreUrl;
  final int points;
  final String category;
  final List<String> steps;
  final DateTime? createdAt;
  final String userId;

  TestApp copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    String? playStoreUrl,
    int? points,
    String? category,
    List<String>? steps,
    DateTime? createdAt,
    String? userId,
  }) {
    return TestApp(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      points: points ?? this.points,
      category: category ?? this.category,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconUrl,
        playStoreUrl,
        points,
        category,
        steps,
        createdAt,
        userId,
      ];
}
