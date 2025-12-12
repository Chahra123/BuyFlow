import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/reglement.dart';

class ReglementService {
  final String baseUrl = "http://192.168.1.15:9091";

  Future<List<Reglement>> getReglements() async {
    final response = await http.get(Uri.parse("$baseUrl/retrieve-all-reglements"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Reglement.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des règlements");
    }
  }

  Future<Reglement> getReglementById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/retrieve-reglement/$id"));

    if (response.statusCode == 200) {
      return Reglement.fromJson(json.decode(response.body));
    } else {
      throw Exception("Règlement introuvable");
    }
  }

  Future<Reglement> addReglement(Reglement r) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add-reglement"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(r.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Reglement.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout du règlement");
    }
  }
}
