import '../../../auth/domain/entities/user.dart';
import '../entities/admin_stats.dart';

abstract class AdminRepository {
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
