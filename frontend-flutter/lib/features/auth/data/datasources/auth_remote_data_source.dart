import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(String email, String password, String firstName, String lastName, String role);
  Future<UserModel> getProfile();
  Future<void> forgotPassword(String email);
  Future<void> updateProfile(String firstName, String lastName, String? avatarUrl);
  Future<String> uploadAvatar(List<int> bytes, String fileName);
  Future<void> verifyEmail(String token);
  Future<void> resetPassword(String token, String newPassword, String confirmPassword);
  Future<void> resendVerificationEmail(String email);
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await dio.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(String email, String password, String firstName, String lastName, String role) async {
    final response = await dio.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    });
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await dio.get(ApiConstants.userProfile);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await dio.post(ApiConstants.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> updateProfile(String firstName, String lastName, String? avatarUrl) async {
    await dio.patch(ApiConstants.updateProfile, data: {
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  @override
  Future<String> uploadAvatar(List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await dio.post(ApiConstants.uploadPhoto, data: formData);
    return response.data.toString();
  }

  @override
  Future<void> verifyEmail(String token) async {
    await dio.get(ApiConstants.verifyEmail, queryParameters: {'token': token});
  }

  @override
  Future<void> resetPassword(String token, String newPassword, String confirmPassword) async {
    await dio.post(ApiConstants.resetPassword, data: {
      'token': token,
      'newPassword': newPassword,
      'confirmationPassword': confirmPassword,
    });
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await dio.post(ApiConstants.resendVerification, queryParameters: {'email': email});
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    await dio.patch(ApiConstants.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmationPassword': confirmPassword,
    });
  }
}
