import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_stats.dart';

abstract class AdminRemoteDataSource {
  Future<List<User>> getUsers({String query = '', int page = 0, int size = 10});
  Future<User> getUser(int id);
  Future<void> deleteUser(int id);
  Future<User> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? password,
  });
  Future<User> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    required bool enabled,
    String? avatarUrl,
  });
  Future<void> toggleUserStatus(int id, bool enabled);
  Future<AdminStats> getStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSourceImpl(this.dio);

  @override
  Future<List<User>> getUsers({String query = '', int page = 0, int size = 10}) async {
    final response = await dio.get(ApiConstants.adminUsers, queryParameters: {
      'query': query,
      'page': page,
      'size': size,
    });
    // Spring Page response: content is the list
    final List<dynamic> content = response.data['content'];
    return content.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<User> getUser(int id) async {
    final response = await dio.get(ApiConstants.adminUser(id));
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> deleteUser(int id) async {
    await dio.delete(ApiConstants.adminUser(id));
  }

  @override
  Future<User> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? password,
  }) async {
    final response = await dio.post(ApiConstants.adminUsers, data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      if (password != null) 'password': password,
    });
    return UserModel.fromJson(response.data);
  }

  @override
  Future<User> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    required bool enabled,
    String? avatarUrl,
  }) async {
    final response = await dio.put(ApiConstants.adminUser(id), data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'enabled': enabled,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> toggleUserStatus(int id, bool enabled) async {
    await dio.patch(ApiConstants.adminUserStatus(id), queryParameters: {'enabled': enabled});
  }

  @override
  Future<AdminStats> getStats() async {
    final response = await dio.get(ApiConstants.adminStats);
    return AdminStats.fromJson(response.data);
  }
}
