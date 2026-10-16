import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
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

// Resets when the signed-in user changes, so one user's photo never shows
// for the next one.
final avatarBytesProvider = StreamProvider<Uint8List?>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));

  if (uid == null) return Stream.value(null);

  return ref.watch(authRepositoryProvider).watchAvatar(uid);
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

  StreamSubscription<fb.User?>? _authSubscription;
  StreamSubscription<AppUser>? _profileSubscription;

  @override
  AuthState build() {
    _authSubscription = _repository.userChanges().listen((fbUser) {
      unawaited(_profileSubscription?.cancel());
      _profileSubscription = null;

      if (fbUser == null) {
        state = const AuthState.signedOut();
        return;
      }

      // Show the initial profile while Firestore loads.
      state = AuthState.signedIn(_repository.toAppUser(fbUser));

      // Create the profile document if it is missing.
      unawaited(_repository.ensureProfile(fbUser));

      // Keep the profile synchronized with Firestore.
      _profileSubscription = _repository
          .profileChanges(fbUser)
          .listen(
            (appUser) {
              if (state.user?.uid == fbUser.uid) {
                state = AuthState.signedIn(appUser);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('Profile stream failed: $error');
            },
          );
    });

    ref.onDispose(() {
      unawaited(_authSubscription?.cancel());
      unawaited(_profileSubscription?.cancel());
    });

    return const AuthState.loading();
  }

  void _refreshFromCurrentUser() {
    final user = _repository.currentUser;
    state = user == null
        ? const AuthState.signedOut()
        : AuthState.signedIn(user);
  }

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

  void saveAvatar(Uint8List bytes) {
    final uid = state.user?.uid;
    if (uid == null) return;

    _repository.saveAvatar(uid, bytes);
  }

  void removeAvatar() {
    final uid = state.user?.uid;
    if (uid == null) return;

    _repository.removeAvatar(uid);
  }
}
