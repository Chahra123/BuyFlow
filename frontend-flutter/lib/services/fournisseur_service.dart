import 'package:dio/dio.dart';
import '../models/fournisseur.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class FournisseurService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<Fournisseur>> getFournisseurs() async {
    try {
      final response = await _dio.get('/fournisseurs');
      final List<dynamic> data = response.data;
      return data.map((e) => Fournisseur.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des fournisseurs: $e");
    }
  }

  Future<Fournisseur> addFournisseur(Fournisseur fournisseur) async {
    try {
      final response = await _dio.post(
        '/fournisseurs',
        data: fournisseur.toJson(),
      );
      return Fournisseur.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du fournisseur: $e");
    }
  }

  Future<Fournisseur> updateFournisseur(Fournisseur fournisseur) async {
    try {
      final response = await _dio.put(
        '/fournisseurs',
        data: fournisseur.toJson(),
      );
      return Fournisseur.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de la modification du fournisseur: $e");
    }
  }

  Future<void> deleteFournisseur(int id) async {
    try {
      await _dio.delete('/fournisseur/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression du fournisseur: $e");
    }
  }

  Future<void> assignSecteurActivite(int idSecteur, int idFournisseur) async {
    try {
      await _dio.put('/assignSecteurActiviteToFournisseur/$idSecteur/$idFournisseur');
    } catch (e) {
      throw Exception("Erreur lors de l'assignation du secteur d'activité: $e");
    }
  }
}
