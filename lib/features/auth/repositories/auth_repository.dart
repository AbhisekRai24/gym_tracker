import 'package:hive_flutter/hive_flutter.dart';

import '../model/user.dart';

class AuthRepository {
  final Box _box;

  AuthRepository(this._box);

  bool get isLoggedIn {
    return _box.get('isLoggedIn', defaultValue: false) as bool;
  }

  User? getUser() {
    final username = _box.get('username');
    final email = _box.get('email');
    final passwordHash = _box.get('passwordHash');
    final avatarPath = _box.get('avatarPath');

    if (username == null || email == null || passwordHash == null) {
      return null;
    }

    return User(
      username: username as String,
      email: email as String,
      passwordHash: passwordHash as String,
      avatarPath: avatarPath as String?,
    );
  }

  bool usernameExists(String username) {
    final savedUsername = _box.get('username');

    if (savedUsername == null) {
      return false;
    }

    return (savedUsername as String).toLowerCase() ==
        username.trim().toLowerCase();
  }

  void saveUser(User user) {
    _box.put('username', user.username);
    _box.put('email', user.email);
    _box.put('passwordHash', user.passwordHash);
    _box.put('avatarPath', user.avatarPath);
  }

  void setLoggedIn(bool value) {
    _box.put('isLoggedIn', value);
  }

  void logout() {
    _box.put('isLoggedIn', false);
  }

  bool updateUsername(String newUsername) {
    final currentUser = getUser();

    if (currentUser == null) {
      return false;
    }

    if (usernameExists(newUsername) &&
        currentUser.username.toLowerCase() !=
            newUsername.trim().toLowerCase()) {
      return false;
    }

    _box.put('username', newUsername.trim());

    return true;
  }

  void updateAvatar(String avatarPath) {
    _box.put('avatarPath', avatarPath);
  }
}
