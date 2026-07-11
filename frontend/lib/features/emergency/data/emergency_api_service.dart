import 'package:dio/dio.dart';
import '../domain/emergency_models.dart';

class EmergencyApiService {
  final Dio _dio;

  EmergencyApiService(this._dio);

  Future<EmergencyRequestModel> createEmergencyRequest(CreateEmergencyRequestDto request) async {
    final response = await _dio.post('/emergencies', data: request.toJson());
    return EmergencyRequestModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<EmergencyRequestModel> getEmergencyRequest(String id) async {
    final response = await _dio.get('/emergencies/$id');
    return EmergencyRequestModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<EmergencyRequestModel>> getMyRequests() async {
    final response = await _dio.get('/emergencies/my-requests');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => EmergencyRequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> cancelRequest(String id, String reason) async {
    await _dio.post('/emergencies/$id/cancel', data: {'reason': reason});
  }

  Future<void> acceptRequest(String id) async {
    await _dio.post('/emergencies/$id/accept');
  }

  Future<void> declineRequest(String id) async {
    await _dio.post('/emergencies/$id/decline');
  }

  Future<List<EmergencyRequestModel>> getActiveEmergencies() async {
    final response = await _dio.get('/emergencies/active');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => EmergencyRequestModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<EmergencyHistoryModel>> getEmergencyHistory(String id) async {
    final response = await _dio.get('/emergencies/$id/history');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => EmergencyHistoryModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
