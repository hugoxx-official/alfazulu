class User {
  final String id;
  final String username;
  final List<String> favorites;
  final bool isPremium;
  final String? premiumPlan;
  final DateTime? subscriptionEnd;

  User({
    required this.id,
    required this.username,
    this.favorites = const [],
    this.isPremium = false,
    this.premiumPlan,
    this.subscriptionEnd,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? subEnd;
    try {
      final subEndValue = json['subscription_end'];
      if (subEndValue != null) {
        subEnd = subEndValue is DateTime ? subEndValue : DateTime.parse(subEndValue.toString());
      }
    } catch (e) {
      print('Error parseando subscription_end: $e');
    }

    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      favorites: json['favorites'] != null ? List<String>.from(json['favorites']) : [],
      isPremium: json['is_premium'] ?? false,
      premiumPlan: json['premium_plan'],
      subscriptionEnd: subEnd,
    );
  }
}
