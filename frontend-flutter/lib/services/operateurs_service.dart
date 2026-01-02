import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/operateur.dart';

class OperateurService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Operateur>> getOperateurs() async {
    final res = await http.get(Uri.parse('$baseUrl/operateurs'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Operateur.fromJson(e)).toList();
    }
    throw Exception('Erreur lors de la récupération des utilisateurs');
  }
}
