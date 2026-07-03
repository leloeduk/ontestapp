import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

/// Modèle de données utilisateur (conversion Firestore <-> [AppUser]).
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
    super.points,
    super.testsDone,
    super.joinedGroup,
    super.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return UserModel(
      uid: uid,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      photoUrl: map['photoUrl'] as String?,
      points: (map['points'] ?? 0) as int,
      testsDone: (map['testsDone'] ?? 0) as int,
      joinedGroup: (map['joinedGroup'] ?? false) as bool,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.id, doc.data() ?? const {});
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'testsDone': testsDone,
      'joinedGroup': joinedGroup,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
