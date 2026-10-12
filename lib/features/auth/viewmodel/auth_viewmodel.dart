import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final box = Hive.box(HiveBoxes.auth);

  return AuthRepository(box);
});

final authViewModelProvider = NotifierProvider<AuthViewModel, bool>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<bool> {
  // Read repository on demand
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  bool build() {
    return ref.watch(authRepositoryProvider).isLoggedIn;
  }

  bool signup(User user) {
    if (_repository.usernameExists(user.username) ||
        _repository.emailExists(user.email)) {
      return false;
    }

    final saved = _repository.saveUser(user);

    if (!saved) {
      return false;
    }

    _repository.setLoggedIn(true);
    state = true;

    return true;
  }

  bool login(String email, String passwordHash) {
    final user = _repository.getUser();

    if (user == null ||
        user.email.toLowerCase() != email.trim().toLowerCase() ||
        user.passwordHash != passwordHash) {
      return false;
    }

    _repository.setLoggedIn(true);
    state = true;

    return true;
  }

  bool resetPassword(String identifier, String newPasswordHash) {
    return _repository.resetPassword(identifier, newPasswordHash);
  }

  void logout() {
    _repository.logout();
    state = false;
  }

  bool updateUsername(String newUsername) {
    final success = _repository.updateUsername(newUsername);
    if (success) {
      // Re-trigger Riverpod notification if needed
      ref.notifyListeners();
    }
    return success;
  }

  void updateAvatar(String avatarPath) {
    _repository.updateAvatar(avatarPath);
    // Force Riverpod to notify UI widgets watching this state to rebuild with new image
    ref.notifyListeners();
  }
}
