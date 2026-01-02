import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/secteur_activite.dart';

class SecteurActiviteService {
  final String baseUrl = "http://192.168.0.145:9091";

  Future<List<SecteurActivite>> getSecteurs() async {
    final response = await http.get(Uri.parse("$baseUrl/secteurs"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => SecteurActivite.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des secteurs d'activité");
    }
  }

  Future<SecteurActivite> addSecteur(SecteurActivite secteur) async {
    final response = await http.post(
      Uri.parse("$baseUrl/secteurs"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(secteur.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SecteurActivite.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout du secteur d'activité");
    }
  }

  Future<SecteurActivite> updateSecteur(SecteurActivite secteur) async {
    final response = await http.put(
      Uri.parse("$baseUrl/secteur-activite"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(secteur.toJson()),
    );

    if (response.statusCode == 200) {
      return SecteurActivite.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la modification du secteur d'activité");
    }
  }

  Future<void> deleteSecteur(int id) async {
    final response =
        await http.delete(Uri.parse("$baseUrl/secteuractivite/$id"));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression du secteur d'activité");
    }
  }
}



