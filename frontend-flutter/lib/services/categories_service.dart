import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/categorie_produit.dart';

class CategorieProduitService {
  final String baseUrl = "http://192.168.1.15:9091";

  Future<List<CategorieProduit>> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => CategorieProduit.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des catégories");
    }
  }

  Future<CategorieProduit> addCategorie(CategorieProduit categorie) async {
    final response = await http.post(
      Uri.parse("$baseUrl/categories"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(categorie.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CategorieProduit.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout de la catégorie");
    }
  }

  Future<CategorieProduit> updateCategorie(CategorieProduit categorie) async {
    final response = await http.put(
      Uri.parse("$baseUrl/categorie-produit"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(categorie.toJson()),
    );

    if (response.statusCode == 200) {
      return CategorieProduit.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la modification de la catégorie");
    }
  }

  Future<void> deleteCategorie(int id) async {
    final response =
    await http.delete(Uri.parse("$baseUrl/categorieproduit/$id"));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression de la catégorie");
    }
  }
}
