import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/admin_stats.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/service_locator.dart';

// Data Source & Repo
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSourceImpl(sl<DioClient>().dio);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.read(adminRemoteDataSourceProvider));
});

// State
class AdminState {
  final List<User> users;
  final User? selectedUser;
  final AdminStats? stats;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.users = const [],
    this.selectedUser,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<User>? users,
    User? selectedUser,
    AdminStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() {
    return const AdminState();
  }

  Future<void> loadUsers({String query = ''}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await ref.read(adminRepositoryProvider).getUsers(query: query);
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUser(int id) async {
    state = state.copyWith(isLoading: true, error: null, selectedUser: null);
    try {
      final user = await ref.read(adminRepositoryProvider).getUser(id);
      state = state.copyWith(isLoading: false, selectedUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await ref.read(adminRepositoryProvider).getStats();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteUser(int id) async {
    // Optimistic update or reload? Let's reload for simplicity or remove from list
    try {
      await ref.read(adminRepositoryProvider).deleteUser(id);
      final updatedList = state.users.where((user) => user.id != id).toList();
      state = state.copyWith(users: updatedList);
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    String? password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(adminRepositoryProvider).createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    required bool enabled,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(adminRepositoryProvider).updateUser(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        enabled: enabled,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(isLoading: false);
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> toggleUserStatus(int id, bool enabled) async {
    try {
      await ref.read(adminRepositoryProvider).toggleUserStatus(id, enabled);
      if (state.selectedUser?.id == id) {
        state = state.copyWith(selectedUser: state.selectedUser?.copyWith(enabled: enabled));
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);
