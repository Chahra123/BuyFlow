import '../../domain/entities/admin_stats.dart';
import '../datasources/admin_remote_data_source.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<User>> getUsers({String query = '', int page = 0, int size = 10}) {
    return remoteDataSource.getUsers(query: query, page: page, size: size);
  }

  @override
  Future<User> getUser(int id) {
    return remoteDataSource.getUser(id);
  }

  @override
  Future<void> deleteUser(int id) {
    return remoteDataSource.deleteUser(id);
  }

  @override
  Future<User> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? password,
  }) {
    return remoteDataSource.createUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      password: password,
    );
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
  }) {
    return remoteDataSource.updateUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      enabled: enabled,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> toggleUserStatus(int id, bool enabled) {
    return remoteDataSource.toggleUserStatus(id, enabled);
  }

  @override
  Future<AdminStats> getStats() {
    return remoteDataSource.getStats();
  }
}
