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
    this.playStoreConfigured = false,
    this.role = 'user',
    this.plan = 'free',
    this.testerEmail,
    this.createdAt,
    this.isDeveloper = false,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final int points;
  final int testsDone;
  final bool joinedGroup;
  final bool playStoreConfigured;
  final String role;
  final String plan;
  final String? testerEmail;
  final DateTime? createdAt;
  final bool isDeveloper;

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
    bool? playStoreConfigured,
    String? role,
    String? plan,
    String? testerEmail,
    bool? isDeveloper,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      testsDone: testsDone ?? this.testsDone,
      joinedGroup: joinedGroup ?? this.joinedGroup,
      playStoreConfigured: playStoreConfigured ?? this.playStoreConfigured,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      testerEmail: testerEmail ?? this.testerEmail,
      createdAt: createdAt,
      isDeveloper: isDeveloper ?? this.isDeveloper,
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
        playStoreConfigured,
        role,
        plan,
        testerEmail,
        createdAt,
        isDeveloper,
      ];
}
