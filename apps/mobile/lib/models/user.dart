class User {
  final String id;
  final String username;
  final List<String> favorites;

  User({
    required this.id,
    required this.username,
    this.favorites = const [],
  });
}
