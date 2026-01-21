import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_models.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

class OrdersService {
  Dio get _dio => sl<DioClient>().dio;

  Future<CustomerOrderDto> createOrder(CreateOrderRequest request) async {
    final res = await _dio.post('/api/orders', data: request.toJson());
    return CustomerOrderDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<CustomerOrderDto>> myOrders() async {
    final res = await _dio.get('/api/orders');
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => CustomerOrderDto.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<CustomerOrderDto> getOrder(int id) async {
    final res = await _dio.get('/api/orders/$id');
    return CustomerOrderDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> cancelOrder(int id) async {
    await _dio.post('/api/orders/$id/cancel');
  }

  Future<String> getQrData(int id) async {
    final res = await _dio.get('/api/orders/$id/qr');
    if (res.data is Map) {
      final map = Map<String, dynamic>.from(res.data);
      return map['qrData']?.toString() ?? '';
    }
    return res.data?.toString() ?? '';
  }

  Future<Uint8List> downloadInvoice(int id) async {
    final res = await _dio.get(
      '/api/orders/$id/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList((res.data as List<int>).toList());
  }
  Future<List<int>> downloadInvoicePdfBytes(int id) async {
	 String baseUrl = 'http://localhost:9091';
    final res = await http.get(Uri.parse('$baseUrl/api/orders/$id/invoice'));
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
    throw Exception('Erreur lors du téléchargement de facture');
  }
}
