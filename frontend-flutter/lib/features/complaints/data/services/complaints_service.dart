import 'package:dio/dio.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dio_client.dart';
import '../models/complaint_models.dart';

class ComplaintsService {
  Dio get _dio => sl<DioClient>().dio;

  Future<ComplaintDto> createComplaint({
    required int orderId,
    required String category,
    required String description,
  }) async {
    final res = await _dio.post('/api/complaints', data: {
      'orderId': orderId,
      'category': category,
      'description': description,
    });
    return ComplaintDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<List<ComplaintDto>> myComplaints() async {
    final res = await _dio.get('/api/complaints');
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => ComplaintDto.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<ComplaintMessageDto>> getMessages(int complaintId) async {
    final res = await _dio.get('/api/complaints/$complaintId');
    final map = Map<String, dynamic>.from(res.data);
    final msgs = (map['messages'] as List?) ?? const [];
    return msgs.map((e) => ComplaintMessageDto.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> sendMessage(int complaintId, String message) async {
    await _dio.post('/api/complaints/$complaintId/messages', data: {'message': message});
  }
}
