import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<_AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUpdateProfileRequested>(_onUpdateProfile);

    _userSub = _authRepository.user.listen(
      (user) => add(_AuthUserChanged(user)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _userSub;

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null && user.isNotEmpty) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        submitting: false,
        clearError: true,
      ));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: _message(e)));
    } catch (_) {
      emit(state.copyWith(submitting: false, errorMessage: 'Une erreur est survenue'));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await _authRepository.signUpWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: _message(e)));
    } catch (_) {
      emit(state.copyWith(submitting: false, errorMessage: 'Une erreur est survenue'));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(submitting: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: _message(e)));
    } catch (_) {
      emit(state.copyWith(submitting: false, errorMessage: 'Connexion Google impossible'));
    }
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.updateProfile(
        state.user.uid,
        name: event.name,
        photoUrl: event.photoUrl,
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Impossible de modifier le profil'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email invalide';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      default:
        return e.message ?? 'Erreur d\'authentification';
    }
  }

  @override
  Future<void> close() {
    _userSub.cancel();
    return super.close();
  }
}
