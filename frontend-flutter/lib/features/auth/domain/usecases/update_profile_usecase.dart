import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(String firstName, String lastName, String? avatarUrl) async {
    return repository.updateProfile(firstName, lastName, avatarUrl);
  }
}
