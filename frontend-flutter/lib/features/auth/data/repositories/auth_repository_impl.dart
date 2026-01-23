import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<User> login(String email, String password) async {
    final authResponse = await remoteDataSource.login(email, password);
    await secureStorage.write(key: 'auth_token', value: authResponse.accessToken);
    await secureStorage.write(key: 'refresh_token', value: authResponse.refreshToken);
    if (authResponse.user != null) return authResponse.user!;
    return await remoteDataSource.getProfile();
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'auth_token', value: accessToken);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  @override
  Future<User> register(String email, String password, String firstName, String lastName, String role) async {
    final authResponse = await remoteDataSource.register(email, password, firstName, lastName, role);
    // On register, backend might only return message if verification is required.
    // If accessToken is present, we log in. 
    if (authResponse.accessToken.isNotEmpty) {
      await secureStorage.write(key: 'auth_token', value: authResponse.accessToken);
      await secureStorage.write(key: 'refresh_token', value: authResponse.refreshToken);
      if (authResponse.user != null) return authResponse.user!;
      return await remoteDataSource.getProfile();
    }
    // Return a dummy user or handle registration-only flow in provider
    return User(id: 0, email: email, firstName: firstName, lastName: lastName, role: role);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> updateProfile(String firstName, String lastName, String? avatarUrl) async {
    await remoteDataSource.updateProfile(firstName, lastName, avatarUrl);
  }

  @override
  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    return await remoteDataSource.uploadAvatar(bytes, fileName);
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'refresh_token');
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token != null) {
      try {
        return await remoteDataSource.getProfile();
      } catch (e) {
        print('AuthRepository: Error getting profile: $e');
        return null;
      }
    }
    print('AuthRepository: No token found in storage');
    return null;
  }

  @override
  Future<void> verifyEmail(String token) async {
    await remoteDataSource.verifyEmail(token);
  }

  @override
  Future<void> resetPassword(String token, String newPassword, String confirmPassword) async {
    await remoteDataSource.resetPassword(token, newPassword, confirmPassword);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await remoteDataSource.resendVerificationEmail(email);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    await remoteDataSource.changePassword(currentPassword, newPassword, confirmPassword);
  }
}
