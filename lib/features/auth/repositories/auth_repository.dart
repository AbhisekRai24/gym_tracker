import 'package:hive_flutter/hive_flutter.dart';

import '../model/user.dart';

class AuthRepository {
  final Box _box;

  AuthRepository(this._box);

  bool get isLoggedIn => _box.get('isLoggedIn', defaultValue: false) as bool;

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

    if (savedUsername == null) return false;

    return (savedUsername as String).trim().toLowerCase() ==
        username.trim().toLowerCase();
  }

  bool emailExists(String email) {
    final savedEmail = _box.get('email');

    if (savedEmail == null) return false;

    return (savedEmail as String).trim().toLowerCase() ==
        email.trim().toLowerCase();
  }

  // Save only when the username and email are not already taken.
  // Returns false if either one belongs to the existing account.
  bool saveUser(User user) {
    final username = user.username.trim();
    final email = user.email.trim().toLowerCase();

    if (usernameExists(username) || emailExists(email)) {
      return false;
    }

    _box.put('username', username);
    _box.put('email', email);
    _box.put('passwordHash', user.passwordHash);
    _box.put('avatarPath', user.avatarPath);

    return true;
  }

  bool resetPassword(String identifier, String newPasswordHash) {
    final user = getUser();

    if (user == null) return false;

    final normalizedIdentifier = identifier.trim().toLowerCase();

    final matchesUsername =
        user.username.trim().toLowerCase() == normalizedIdentifier;
    final matchesEmail =
        user.email.trim().toLowerCase() == normalizedIdentifier;

    if (!matchesUsername && !matchesEmail) return false;

    _box.put('passwordHash', newPasswordHash);
    return true;
  }

  void setLoggedIn(bool value) {
    _box.put('isLoggedIn', value);
  }

  void logout() {
    _box.put('isLoggedIn', false);
  }

  bool updateUsername(String newUsername) {
    final currentUser = getUser();

    if (currentUser == null) return false;

    final normalizedNew = newUsername.trim().toLowerCase();
    final normalizedCurrent = currentUser.username.trim().toLowerCase();

    if (usernameExists(newUsername) && normalizedCurrent != normalizedNew) {
      return false;
    }

    _box.put('username', newUsername.trim());
    return true;
  }

  void updateAvatar(String avatarPath) {
    _box.put('avatarPath', avatarPath);
  }
}
