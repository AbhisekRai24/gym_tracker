import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:hive_flutter/hive_flutter.dart';

import '../model/user.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth;
  final Box _profileBox;

  AuthRepository(this._auth, this._profileBox);

  Stream<fb.User?> userChanges() => _auth.userChanges();

  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : toAppUser(user);
  }

  String _avatarKey(String uid) => 'avatar_$uid';

  AppUser toAppUser(fb.User user) {
    final email = user.email ?? '';
    final name = (user.displayName ?? '').trim();

    return AppUser(
      uid: user.uid,
      username: name.isNotEmpty
          ? name
          : (email.contains('@') ? email.split('@').first : 'User'),
      email: email,
      avatarPath: _profileBox.get(_avatarKey(user.uid)) as String?,
    );
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    await credential.user?.updateDisplayName(username.trim());
    await credential.user?.reload();
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> logout() => _auth.signOut();

  Future<void> updateUsername(String newUsername) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(newUsername.trim());
    await user.reload();
  }

  Future<void> updateAvatar(String uid, String path) async {
    await _profileBox.put(_avatarKey(uid), path);
  }

  static String errorMessage(Object error) {
    if (error is fb.FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists. Please log in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 8 characters.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a bit and try again.';
        case 'network-request-failed':
          return 'No internet connection. Check your network and try again.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled in Firebase yet.';
        default:
          return 'Something went wrong (${error.code}). Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}