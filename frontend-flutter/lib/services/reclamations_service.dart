import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/reclamation.dart';

class ReclamationService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Reclamation>> listByOperateur(int operateurId) async {
    final res = await http.get(Uri.parse('$baseUrl/reclamations?operateurId=$operateurId'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Reclamation.fromJson(e)).toList();
    }
    throw Exception('Erreur lors de la récupération des réclamations');
  }

  Future<Reclamation> create({
    required int operateurId,
    required int commandeId,
    required String objet,
    required String description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reclamations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'operateurId': operateurId,
        'commandeId': commandeId,
        'objet': objet,
        'description': description,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Reclamation.fromJson(json.decode(res.body));
    }
    throw Exception('Erreur lors de la création de la réclamation');
  }
}
