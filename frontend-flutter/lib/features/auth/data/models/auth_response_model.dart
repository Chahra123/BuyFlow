import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String? message;
  final UserModel? user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.message,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      message: json['message'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
