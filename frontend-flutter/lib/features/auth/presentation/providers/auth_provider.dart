import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/user.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/di/service_locator.dart';

// Data Sources & Repositories
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(sl<DioClient>().dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    sl<FlutterSecureStorage>(),
  );
});

// Use Cases
final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));
final forgotPasswordUseCaseProvider = Provider((ref) => ForgotPasswordUseCase(ref.read(authRepositoryProvider)));
final updateProfileUseCaseProvider = Provider((ref) => UpdateProfileUseCase(ref.read(authRepositoryProvider)));

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool? success;
  final String? message;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.success,
    this.message,
    this.isInitialized = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? success,
    String? message,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
      message: message ?? this.message,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Initial state
    _initialize();
    return const AuthState();
  }

  Future<void> _initialize() async {
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(user: user, isInitialized: true);
    } catch (e) {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final user = await loginUseCase(email, password);
      state = state.copyWith(isLoading: false, user: user, success: true);
      return true;
    } catch (e) {
      String errorMessage = "Identifiants incorrects";
      if (e is DioException && e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage, success: false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName, String lastName, String role) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      final user = await registerUseCase(email, password, firstName, lastName, role);
      
      // If user id is 0, it means registration success but login pending (verification)
      if (user.id == 0) {
        state = state.copyWith(isLoading: false, success: true, message: "Compte créé. Vérifiez vos emails.");
      } else {
        state = state.copyWith(isLoading: false, user: user, success: true);
      }
      return true;
    } catch (e) {
      String errorMessage = "Erreur lors de l'inscription";
      if (e is DioException && e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage, success: false);
      return false;
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
      await forgotPasswordUseCase(email);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
      return false;
    }
  }

  Future<bool> updateProfile(String firstName, String lastName, String? avatarUrl) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await ref.read(authRepositoryProvider).updateProfile(firstName, lastName, avatarUrl);
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(isLoading: false, user: user, success: true);
      return true;
    } catch (e) {
      String errorMessage = "Erreur lors de la mise à jour";
      if (e is DioException && e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage, success: false);
      return false;
    }
  }

  Future<bool> uploadAvatar(List<int> bytes, String fileName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final avatarUrl = await ref.read(authRepositoryProvider).uploadAvatar(bytes, fileName);
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      state = state.copyWith(isLoading: false, user: user, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(isInitialized: true);
  }

  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await ref.read(authRepositoryProvider).changePassword(currentPassword, newPassword, confirmPassword);
      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      String errorMessage = "Erreur lors du changement de mot de passe";
      if (e is DioException && e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage, success: false);
      return false;
    }
  }

  Future<void> handleOAuth2Success(String accessToken, String refreshToken) async {
    print('AuthNotifier: handleOAuth2Success started');
    state = state.copyWith(isLoading: true);
    try {
      print('AuthNotifier: saving tokens');
      await ref.read(authRepositoryProvider).saveTokens(accessToken, refreshToken);
      
      print('AuthNotifier: getting current user');
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      
      if (user != null) {
        print('AuthNotifier: login success for ${user.email}');
        state = state.copyWith(isLoading: false, user: user, success: true);
      } else {
        print('AuthNotifier: login failed - user is null');
        state = state.copyWith(isLoading: false, error: "Erreur lors de la récupération du profil", success: false);
      }
    } catch (e) {
      print('AuthNotifier: OAuth2 error: $e');
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
    }
  }

  Future<bool> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).verifyEmail(token);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword, String confirmPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).resetPassword(token, newPassword, confirmPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
