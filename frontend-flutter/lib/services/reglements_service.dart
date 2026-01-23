import 'package:dio/dio.dart';
import '../models/reglement.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class ReglementService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<Reglement>> getReglements() async {
    try {
      final response = await _dio.get('/retrieve-all-reglements');
      final List<dynamic> data = response.data;
      return data.map((e) => Reglement.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des règlements: $e");
    }
  }

  Future<Reglement> getReglementById(int id) async {
    try {
      final response = await _dio.get('/retrieve-reglement/$id');
      return Reglement.fromJson(response.data);
    } catch (e) {
      throw Exception("Règlement introuvable: $e");
    }
  }

  Future<Reglement> addReglement(Reglement r) async {
    try {
      final response = await _dio.post(
        '/add-reglement',
        data: r.toJson(),
      );
      return Reglement.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du règlement: $e");
    }
  }
}
