class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:9091';

  // Auth
  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';

  // Users
  static const String userProfile = '/api/users/me';
  static const String updateProfile = '/api/users/me';
  static const String uploadPhoto = '/api/users/me/photo';
  static const String changePassword = '/api/users/me/change-password';

  // Admin
  static const String adminUsers = '/api/admin/users';
  static String adminUser(int id) => '/api/admin/users/$id';
  static String adminUserStatus(int id) => '/api/admin/users/$id/status';
  static const String adminStats = '/api/admin/stats';
}
