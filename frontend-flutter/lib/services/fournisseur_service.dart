import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fournisseur.dart';

class FournisseurService {
  final String baseUrl = "http://192.168.0.145:9091";

  Future<List<Fournisseur>> getFournisseurs() async {
    final response = await http.get(Uri.parse("$baseUrl/fournisseurs"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Fournisseur.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des fournisseurs");
    }
  }

  Future<Fournisseur> getFournisseurById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Fournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception("Fournisseur introuvable");
    }
  }

  Future<Fournisseur> addFournisseur(Fournisseur fournisseur) async {
    final response = await http.post(
      Uri.parse("$baseUrl/fournisseurs"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(fournisseur.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Fournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout du fournisseur");
    }
  }

  Future<Fournisseur> updateFournisseur(Fournisseur fournisseur) async {
    final response = await http.put(
      Uri.parse("$baseUrl/fournisseurs"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(fournisseur.toJson()),
    );

    if (response.statusCode == 200) {
      return Fournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la modification du fournisseur");
    }
  }

  Future<void> deleteFournisseur(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/fournisseur/$id"));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression du fournisseur");
    }
  }

  Future<void> assignSecteurActiviteToFournisseur(
      int idSecteurActivite, int idFournisseur) async {
    final response = await http.put(
      Uri.parse(
          "$baseUrl/assignSecteurActiviteToFournisseur/$idSecteurActivite/$idFournisseur"),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Erreur lors de l'assignation du secteur d'activité au fournisseur");
    }
  }
}

