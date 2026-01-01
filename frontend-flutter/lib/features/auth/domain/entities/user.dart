class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool enabled;
  final DateTime? createdAt;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.enabled = true,
    this.createdAt,
    this.avatarUrl,
  });

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    bool? enabled,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
