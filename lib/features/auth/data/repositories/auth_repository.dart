import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Abstraction de l'authentification pour les Blocs.
class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  final AuthService _authService;
  final UserService _userService;

  /// Flux de l'utilisateur courant (null si déconnecté), réactif aux
  /// changements du document Firestore (points, groupe rejoint, etc.).
  Stream<AppUser?> get user {
    final controller = StreamController<AppUser?>();
    StreamSubscription<UserModel?>? docSub;

    final authSub = _authService.authStateChanges().listen((fbUser) {
      docSub?.cancel();
      if (fbUser == null) {
        controller.add(null);
        return;
      }
      docSub = _userService.watchUser(fbUser.uid).listen((model) {
        controller.add(
          model ??
              AppUser(
                uid: fbUser.uid,
                name: fbUser.displayName ?? '',
                email: fbUser.email ?? '',
              ),
        );
      });
    });

    controller.onCancel = () async {
      await docSub?.cancel();
      await authSub.cancel();
    };

    return controller.stream;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmail(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred =
        await _authService.signUpWithEmail(email: email, password: password);
    await _authService.updateDisplayName(name);
    final uid = cred.user!.uid;
    await _userService.createUserIfMissing(
      UserModel(uid: uid, name: name, email: email),
    );
  }

  Future<void> signInWithGoogle() async {
    final cred = await _authService.signInWithGoogle();
    if (cred == null) return; // annulé par l'utilisateur
    final user = cred.user!;
    await _userService.createUserIfMissing(
      UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Utilisateur',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      ),
    );
  }

  Future<void> signOut() => _authService.signOut();

  /// Marque l'utilisateur comme ayant rejoint le groupe.
  Future<void> joinGroup(String uid) => _userService.updateJoinedGroup(uid, true);

  Future<void> updateTesterEmail(String uid, String email) =>
      _userService.updateTesterEmail(uid, email);

  Future<void> updatePlayStoreConfigured(String uid) =>
      _userService.updatePlayStoreConfigured(uid);

  Future<void> updateProfile(String uid, {String? name, String? photoUrl}) =>
      _userService.updateUser(uid, {
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

  Future<void> updateIsDeveloper(String uid, bool value) =>
      _userService.updateUser(uid, {'isDeveloper': value});
}
