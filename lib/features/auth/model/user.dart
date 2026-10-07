class User {
  final String username;
  final String email;
  final String passwordHash;
  final String? avatarPath;


  const User({
    required this.username,
    required this.email,
    required this.passwordHash,
    this.avatarPath,
  });
}
