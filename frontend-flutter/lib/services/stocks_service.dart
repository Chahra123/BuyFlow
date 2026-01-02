import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/stock.dart';

class StockService {
  final String baseUrl = "http://192.168.0.145:9091/stocks"; //Laptop ip address

  Future<List<Stock>> getStocks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Stock.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la récupération des stocks");
    }
  }

  Future<Stock> getStockById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    

    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw Exception("Stock introuvable");
    }
  }

  Future<Stock> addStock(Stock stock) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(stock.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de l'ajout du stock");
    }
  }

  Future<Stock> updateStock(Stock stock) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(stock.toJson()),
    );

    if (response.statusCode == 200) {
      return Stock.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur lors de la modification");
    }
  }

  Future<void> deleteStock(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression");
    }
  }
}