import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/commande.dart';

class CommandeService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<Commande>> getMesCommandes({required int operateurId}) async {
    final res = await http.get(Uri.parse('$baseUrl/commandes?operateurId=$operateurId'));
    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    throw Exception('Erreur lors de la récupération des commandes');
  }

  Future<Commande> createCommande({
    required int operateurId,
    required int produitId,
    required int quantite,
    required String adresse,
    double? latitude,
    double? longitude,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/commandes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'operateurId': operateurId,
        'produitId': produitId,
        'quantite': quantite,
        'adresseLivraison': adresse,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Commande.fromJson(json.decode(res.body));
    }
    throw Exception('Erreur lors de la création de commande');
  }

  Future<Commande> confirmCommande(int commandeId) async {
    final res = await http.put(Uri.parse('$baseUrl/commandes/$commandeId/confirm'));
    if (res.statusCode == 200) {
      return Commande.fromJson(json.decode(res.body));
    }
    throw Exception('Erreur lors de la confirmation');
  }

  Future<List<int>> downloadInvoicePdfBytes(int commandeId) async {
    final res = await http.get(Uri.parse('$baseUrl/commandes/$commandeId/invoice.pdf'));
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Erreur lors du téléchargement de facture');
  }
}
