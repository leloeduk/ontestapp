import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.photoUrl,
    super.points,
    super.testsDone,
    super.joinedGroup,
    super.playStoreConfigured,
    super.role,
    super.plan,
    super.testerEmail,
    super.createdAt,
    super.isDeveloper,
    super.isAdmin,
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
      playStoreConfigured: (map['playStoreConfigured'] ?? false) as bool,
      role: (map['role'] ?? 'user') as String,
      plan: (map['plan'] ?? 'free') as String,
      testerEmail: map['testerEmail'] as String?,
      isDeveloper: (map['isDeveloper'] ?? false) as bool,
      isAdmin: (map['isAdmin'] ?? false) as bool,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Object?> doc) {
    return UserModel.fromMap(doc.id, (doc.data() as Map<String, dynamic>?) ?? const {});
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'testsDone': testsDone,
      'joinedGroup': joinedGroup,
      'playStoreConfigured': playStoreConfigured,
      'role': role,
      'plan': plan,
      'testerEmail': testerEmail,
      'isDeveloper': isDeveloper,
      'isAdmin': isAdmin,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
