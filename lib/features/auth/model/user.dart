class AppUser {
  final String uid;
  final String username;
  final String email;
  final String? avatarPath;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.avatarPath,
  });
}
