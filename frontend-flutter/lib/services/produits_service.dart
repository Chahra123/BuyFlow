import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/MouvementStock.dart';
import '../models/produit.dart';

class ProduitService {
  final String baseUrl = "http://192.168.0.145:9091";

  Future<List<Produit>> getProduits() async {
    final response = await http.get(Uri.parse("$baseUrl/prdouits"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des produits");
    }
  }

  Future<Produit> addProduit(Produit produit) async {
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

  Future<void> assignProduitToStock(int idProduit, int idStock) async {
    final response = await http.put(
      Uri.parse("$baseUrl/assignProduitToStock/$idProduit/$idStock"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de l'assignation au stock");
    }
  }

  Future<List<Produit>> getProduitsByStock(int idStock) async {
    final response = await http.get(
      Uri.parse("$baseUrl/getProduitByStock/$idStock"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des produits par stock");
    }
  }

  Future<void> removeProduitFromStock(int idProduit) async {
    final response = await http.put(
      Uri.parse("$baseUrl/removeProduitFromStock/$idProduit"),
    );
    if (response.statusCode != 200) {
      throw Exception("Erreur désassignation");
    }
  }

  Future<MouvementStock> effectuerMouvement({
    required int produitId,
    required int quantite,
    required String type, // "ENTREE" ou "SORTIE"
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/mouvements"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "produitId": produitId,
        "quantite": quantite,
        "type": type,
      }),
    );

    if (response.statusCode == 200) {
      return MouvementStock.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors du mouvement de stock");
    }
  }

  Future<int> getQuantiteProduit(int produitId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/produits/$produitId/quantite"),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception("Erreur lors du chargement de la quantité du produit");
    }
  }

}
