import 'package:dio/dio.dart';
import '../models/MouvementStock.dart';
import '../models/produit.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class ProduitService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<Produit>> getProduits() async {
    try {
      final response = await _dio.get('/produits');
      final List<dynamic> data = response.data;
      return data.map((json) => Produit.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des produits: $e");
    }
  }

  Future<Produit> addProduit(Produit produit) async {
    try {
      final response = await _dio.post(
        '/produits',
        data: produit.toJson(),
      );
      return Produit.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du produit: $e");
    }
  }

  Future<Produit> updateProduit(Produit produit) async {
    try {
      final response = await _dio.put(
        '/produits',
        data: produit.toJson(),
      );
      return Produit.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de la modification du produit: $e");
    }
  }

  Future<void> deleteProduit(int id) async {
    try {
      await _dio.delete('/produits/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression du produit: $e");
    }
  }

  Future<void> assignProduitToStock(
    int idProduit,
    int idStock,
    int qteInitiale,
  ) async {
    try {
      await _dio.put(
        '/produits/assignProduitToStock/$idProduit/$idStock',
        queryParameters: {'qteInitiale': qteInitiale},
      );
    } catch (e) {
      throw Exception("Erreur lors de l'assignation au stock: $e");
    }
  }

  Future<List<Produit>> getProduitsByStock(int idStock) async {
    try {
      final response = await _dio.get(
        '/produits/getProduitByStock/$idStock',
      );
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => Produit.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Erreur lors du chargement des produits par stock: $e");
    }
  }

  Future<void> removeProduitFromStock(int idProduit) async {
    try {
      await _dio.put(
        '/produits/removeProduitFromStock/$idProduit',
      );
    } catch (e) {
      throw Exception("Erreur désassignation: $e");
    }
  }

  Future<MouvementStock> effectuerMouvement({
    required int produitId,
    required int quantite,
    required String type, // "ENTREE" ou "SORTIE"
    String? raison,
    String? utilisateur,
  }) async {
    if (type == "SORTIE") {
      int qteDisponible = await getQuantiteProduit(produitId);
      if (qteDisponible < quantite) {
        throw Exception("Quantité insuffisante");
      }
    }
    try {
      final response = await _dio.post(
        '/mouvements',
        data: {
          "produitId": produitId,
          "quantite": quantite,
          "type": type,
          "raison": raison,
          "utilisateur": utilisateur,
        },
      );
      return MouvementStock.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors du mouvement de stock: $e");
    }
  }

  Future<List<MouvementStock>> getMouvementsProduit(int produitId) async {
    try {
      final response = await _dio.get(
        '/produits/$produitId/mouvements',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => MouvementStock.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des mouvements: $e");
    }
  }

  Future<int> getQuantiteProduit(int produitId) async {
    try {
      final response = await _dio.get(
        '/produits/$produitId/quantite',
      );
      return response.data is int ? response.data : int.parse(response.data.toString());
    } catch (e) {
      throw Exception("Erreur lors du chargement de la quantité du produit: $e");
    }
  }
}
