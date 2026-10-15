import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../model/user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    fb.FirebaseAuth.instance,
    FirebaseFirestore.instance,
    Hive.box(HiveBoxes.profile),
  );
});
enum AuthStatus { loading, signedOut, signedIn }

class AuthState {
  final AuthStatus status;
  final AppUser? user;

  const AuthState._(this.status, this.user);
  const AuthState.loading() : this._(AuthStatus.loading, null);
  const AuthState.signedOut() : this._(AuthStatus.signedOut, null);
  const AuthState.signedIn(AppUser user) : this._(AuthStatus.signedIn, user);

  bool get isSignedIn => status == AuthStatus.signedIn;
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    final subscription = _repository.userChanges().listen(
        (fbUser) {
        if (fbUser == null) {
          state = const AuthState.signedOut();
          return;
        }

        state = AuthState.signedIn(_repository.toAppUser(fbUser));
        unawaited(_repository.ensureProfile(fbUser));
      },
    );

    ref.onDispose(subscription.cancel);

    return const AuthState.loading();
  }

  void _refreshFromCurrentUser() {
    final user = _repository.currentUser;
    state = user == null
        ? const AuthState.signedOut()
        : AuthState.signedIn(user);
  }

  // Each action returns null on success, or a readable error message.

  Future<String?> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _repository.signUp(
        username: username,
        email: email,
        password: password,
      );
      _refreshFromCurrentUser();
      return null;
    } catch (e) {
      return AuthRepository.errorMessage(e);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _repository.login(email, password);
      return null;
    } catch (e) {
      return AuthRepository.errorMessage(e);
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordReset(email);
      return null;
    } catch (e) {
      return AuthRepository.errorMessage(e);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  Future<String?> updateUsername(String newUsername) async {
    try {
      await _repository.updateUsername(newUsername);
      _refreshFromCurrentUser();
      return null;
    } catch (e) {
      return AuthRepository.errorMessage(e);
    }
  }

  Future<void> updateAvatar(String path) async {
    final user = state.user;
    if (user == null) return;

    await _repository.updateAvatar(user.uid, path);
    _refreshFromCurrentUser();
  }
}