import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.points = 0,
    this.testsDone = 0,
    this.joinedGroup = false,
    this.role = 'user',
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int points;
  final int testsDone;
  final bool joinedGroup;
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  static const AppUser empty = AppUser(uid: '', name: '', email: '');

  bool get isEmpty => uid.isEmpty;
  bool get isNotEmpty => uid.isNotEmpty;

  AppUser copyWith({
    String? name,
    String? photoUrl,
    int? points,
    int? testsDone,
    bool? joinedGroup,
    String? role,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      testsDone: testsDone ?? this.testsDone,
      joinedGroup: joinedGroup ?? this.joinedGroup,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        photoUrl,
        points,
        testsDone,
        joinedGroup,
        role,
        createdAt,
      ];
}
