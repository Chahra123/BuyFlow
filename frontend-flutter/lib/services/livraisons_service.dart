import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/livraison.dart';

class LivraisonService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Livraison>> listAll() async {
    final res = await http.get(Uri.parse('$baseUrl/livraisons'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Livraison.fromJson(e)).toList();
    }
    throw Exception('Erreur lors de la récupération des livraisons');
  }

  Future<Livraison> updateStatusByQr({
    required String qrToken,
    required String status,
    required int updatedByOperateurId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/livraisons/scan'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'qrToken': qrToken,
        'status': status,
        'updatedByOperateurId': updatedByOperateurId,
      }),
    );
    if (res.statusCode == 200) {
      return Livraison.fromJson(json.decode(res.body));
    }
    throw Exception('Erreur lors de la mise à jour de statut');
  }
}
