import 'package:dio/dio.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../../../commerce/data/models/order_models.dart';

class DeliveryService {
  Dio get _dio => sl<DioClient>().dio;

  Future<List<CustomerOrderDto>> assignedOrders() async {
    final res = await _dio.get('/api/delivery/orders');
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => CustomerOrderDto.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> startDelivery(int orderId) async {
    await _dio.post('/api/delivery/orders/$orderId/start');
  }

  Future<void> scanAndDeliver({required int orderId, required String qrData}) async {
    await _dio.post('/api/delivery/orders/$orderId/scan', data: {'qrData': qrData});
  }
}
