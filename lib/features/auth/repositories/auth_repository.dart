import 'package:gym_track/features/auth/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';

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

    if (username == null || email == null || passwordHash == null) {
      return null;
    }

    return User(
      username: username as String,
      email: email as String,
      passwordHash: passwordHash as String,
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
  }

  void setLoggedIn(bool value) {
    _box.put('isLoggedIn', value);
  }

  void logout() {
    _box.put('isLoggedIn', false);
  }
}