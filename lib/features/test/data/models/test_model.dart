import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/test_app.dart';

/// Modèle Firestore <-> [TestApp].
class TestModel extends TestApp {
  const TestModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconUrl,
    required super.playStoreUrl,
    required super.points,
    super.category,
    super.steps,
    super.createdAt,
    super.userId,
  });

  factory TestModel.fromSnapshot(DocumentSnapshot<Object?> doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? const {};
    final createdAt = map['createdAt'];
    return TestModel(
      id: doc.id,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      iconUrl: (map['iconUrl'] ?? '') as String,
      playStoreUrl: (map['playStoreUrl'] ?? '') as String,
      points: (map['points'] ?? 0) as int,
      category: (map['category'] ?? '') as String,
      steps: (map['steps'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      userId: (map['userId'] ?? '') as String,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'playStoreUrl': playStoreUrl,
      'points': points,
      'category': category,
      'steps': steps,
      'userId': userId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
