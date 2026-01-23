import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<int>>(
      (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super(<int>{});

  final DioClient _dioClient = sl<DioClient>();

  // =========================
  // INITIALISATION (appelée depuis le Shop)
  // =========================
  Future<void> loadFavorites() async {
    try {
      final response = await _dioClient.dio.get('/api/favorites');

      final ids = <int>{};
      for (final product in response.data) {
        // ⚠️ adapte si ton champ s’appelle autrement
        ids.add(product['idProduit'] as int);
      }

      state = ids;
    } catch (e) {
      // on ne bloque pas l’UI en cas d’erreur
    }
  }

  // =========================
  // LECTURE
  // =========================
  bool isFavorite(int produitId) {
    return state.contains(produitId);
  }

  // =========================
  // AJOUT (optimistic)
  // =========================
  Future<void> addFavorite(int produitId) async {
    if (state.contains(produitId)) return;

    final previousState = state;
    state = {...state, produitId};

    try {
      await _dioClient.dio.post('/api/favorites/$produitId');
    } catch (e) {
      state = previousState; // rollback
    }
  }

  // =========================
  // SUPPRESSION (optimistic)
  // =========================
  Future<void> removeFavorite(int produitId) async {
    if (!state.contains(produitId)) return;

    final previousState = state;
    state = state.where((id) => id != produitId).toSet();

    try {
      await _dioClient.dio.delete('/api/favorites/$produitId');
    } catch (e) {
      state = previousState; // rollback
    }
  }

  // =========================
  // RESET (optionnel)
  // =========================
  void clearFavorites() {
    state = <int>{};
  }
}
