import 'package:dio/dio.dart';
import '../models/categorie_produit.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class CategorieProduitService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<CategorieProduit>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data;
      return data.map((e) => CategorieProduit.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des catégories: $e");
    }
  }

  Future<CategorieProduit> addCategorie(CategorieProduit categorie) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: categorie.toJson(),
      );
      return CategorieProduit.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout de la catégorie: $e");
    }
  }

  Future<CategorieProduit> updateCategorie(CategorieProduit categorie) async {
    try {
      final response = await _dio.put(
        '/categorie-produit',
        data: categorie.toJson(),
      );
      return CategorieProduit.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de la modification de la catégorie: $e");
    }
  }

  Future<void> deleteCategorie(int id) async {
    try {
      await _dio.delete('/categorieproduit/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression de la catégorie: $e");
    }
  }
}
