import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<User> register(String email, String password, String firstName, String lastName, String role);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<void> updateProfile(String firstName, String lastName, String? avatarUrl);
  Future<String> uploadAvatar(List<int> bytes, String fileName);
  Future<User?> getCurrentUser();
  Future<void> verifyEmail(String token);
  Future<void> resetPassword(String token, String newPassword, String confirmPassword);
  Future<void> resendVerificationEmail(String email);
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword);
}
