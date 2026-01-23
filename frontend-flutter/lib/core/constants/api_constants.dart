class ApiConstants {
  static const String baseUrl = 'http://localhost:9091';

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
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadPhoto = '/users/me/photo';
  static const String changePassword = '/users/me/change-password';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUser(int id) => '/admin/users/$id';
  static String adminUserStatus(int id) => '/admin/users/$id/status';
  static const String adminStats = '/admin/stats';
}
