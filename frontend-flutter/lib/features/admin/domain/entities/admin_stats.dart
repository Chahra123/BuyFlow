class AdminStats {
  final int totalUsers;
  final int enabledUsers;
  final int adminUsers;
  final int newUsersLast24h;

  const AdminStats({
    this.totalUsers = 0,
    this.enabledUsers = 0,
    this.adminUsers = 0,
    this.newUsersLast24h = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      enabledUsers: json['enabledUsers'] ?? 0,
      adminUsers: json['adminUsers'] ?? 0,
      newUsersLast24h: json['newUsersLast24h'] ?? 0,
    );
  }
}
