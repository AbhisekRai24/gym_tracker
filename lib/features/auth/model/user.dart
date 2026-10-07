class User {
  final String username;
  final String email;
  final String passwordHash;

  const User({
    required this.username,
    required this.email,
    required this.passwordHash,
  });
}
