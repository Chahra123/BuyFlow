import 'package:dio/dio.dart';
import '../models/secteur_activite.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class SecteurActiviteService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<SecteurActivite>> getSecteurs() async {
    try {
      final response = await _dio.get('/secteurs');
      final List<dynamic> data = response.data;
      return data.map((e) => SecteurActivite.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des secteurs d'activité: $e");
    }
  }

  Future<SecteurActivite> addSecteur(SecteurActivite secteur) async {
    try {
      final response = await _dio.post(
        '/secteurs',
        data: secteur.toJson(),
      );
      return SecteurActivite.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du secteur d'activité: $e");
    }
  }

  Future<SecteurActivite> updateSecteur(SecteurActivite secteur) async {
    try {
      final response = await _dio.put(
        '/secteur-activite',
        data: secteur.toJson(),
      );
      return SecteurActivite.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de la modification du secteur d'activité: $e");
    }
  }

  Future<void> deleteSecteur(int id) async {
    try {
      await _dio.delete('/secteuractivite/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression du secteur d'activité: $e");
    }
  }
}
