import 'package:dio/dio.dart';
import '../models/stock.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

class StockService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<Stock>> getStocks() async {
    try {
      final response = await _dio.get('/stocks');
      final List<dynamic> data = response.data;
      return data.map((json) => Stock.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des stocks: $e");
    }
  }

  Future<Stock> getStockById(int id) async {
    try {
      final response = await _dio.get('/stocks/$id');
      return Stock.fromJson(response.data);
    } catch (e) {
      throw Exception("Stock introuvable: $e");
    }
  }

  Future<Stock> addStock(Stock stock) async {
    try {
      final response = await _dio.post(
        '/stocks',
        data: stock.toJson(),
      );
      return Stock.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du stock: $e");
    }
  }

  Future<Stock> updateStock(Stock stock) async {
    try {
      final response = await _dio.put(
        '/stocks',
        data: stock.toJson(),
      );
      return Stock.fromJson(response.data);
    } catch (e) {
      throw Exception("Erreur lors de la modification: $e");
    }
  }

  Future<void> deleteStock(int id) async {
    try {
      await _dio.delete('/stocks/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression: $e");
    }
  }

  Future<int> getQteTotale(int idStock) async {
    try {
      final response = await _dio.get('/stocks/$idStock/qteTotale');
      return response.data is int ? response.data : int.parse(response.data.toString());
    } catch (e) {
      throw Exception("Erreur lors de la récupération de qteTotale: $e");
    }
  }

  Future<Map<String, dynamic>> getStockStats() async {
    try {
      final response = await _dio.get('/stocks/stats');
      return response.data;
    } catch (e) {
      throw Exception("Erreur stats stock: $e");
    }
  }

  Future<List<dynamic>> getMouvements() async {
    try {
      final response = await _dio.get('/mouvements');
      return response.data;
    } catch (e) {
      throw Exception("Erreur mouvements: $e");
    }
  }
}