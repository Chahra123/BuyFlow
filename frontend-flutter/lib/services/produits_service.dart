import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/produit.dart';

class ProduitService {
  final String baseUrl = "http://192.168.1.15:9091";

  Future<List<Produit>> getProduits() async {
    // ⚠️ backend endpoint écrit "/prdouits" (typo) donc on l'utilise tel quel
    final response = await http.get(Uri.parse("$baseUrl/prdouits"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des produits");
    }
  }

  Future<Produit> addProduit(Produit produit) async {
    // ⚠️ backend: @PostMapping sans path => POST "/"
    // Donc on doit appeler baseUrl + "/"
    final response = await http.post(
      Uri.parse("$baseUrl/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(produit.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Produit.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout du produit");
    }
  }

  Future<Produit> updateProduit(Produit produit) async {
    final response = await http.put(
      Uri.parse("$baseUrl/produits"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(produit.toJson()),
    );

    if (response.statusCode == 200) {
      return Produit.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la modification du produit");
    }
  }

  Future<void> deleteProduit(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/produit/$id"));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression du produit");
    }
  }
}
