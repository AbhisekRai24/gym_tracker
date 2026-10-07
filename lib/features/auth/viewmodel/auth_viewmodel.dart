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
  late final AuthRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(authRepositoryProvider);

    return _repository.isLoggedIn;
  }

  bool signup(User user) {
    if (_repository.usernameExists(user.username)) {
      return false;
    }

    _repository.saveUser(user);
    _repository.setLoggedIn(true);

    state = true;

    return true;
  }

  bool login(String email, String passwordHash) {
    final user = _repository.getUser();

    if (user == null) {
      return false;
    }

    if (user.email != email) {
      return false;
    }

    if (user.passwordHash != passwordHash) {
      return false;
    }

    _repository.setLoggedIn(true);
    state = true;

    return true;
  }

  void logout() {
    _repository.logout();

    state = false;
  }

  bool updateUsername(String newUsername) {
    return _repository.updateUsername(newUsername);
  }

  void updateAvatar(String avatarPath) {
  _repository.updateAvatar(avatarPath);

  ref.invalidate(authRepositoryProvider);
}
}
