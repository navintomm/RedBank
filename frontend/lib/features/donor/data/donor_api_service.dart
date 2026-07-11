import 'package:dio/dio.dart';
import '../domain/donor_models.dart';

class DonorApiService {
  final Dio _dio;

  DonorApiService(this._dio);

  Future<DonorProfileDto> getProfile() async {
    final response = await _dio.get('/donors/profile');
    // Assuming backend returns ApiResponse envelope: { success: true, data: { ... } }
    return DonorProfileDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DonorProfileDto> createOrUpdateProfile(UpdateDonorProfileRequest request) async {
    final response = await _dio.post('/donors/profile', data: request.toJson());
    return DonorProfileDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DonorProfileDto> updateProfile(UpdateDonorProfileRequest request) async {
    final response = await _dio.put('/donors/profile', data: request.toJson());
    return DonorProfileDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<DonorProfileDto> updateAvailability(UpdateAvailabilityRequest request) async {
    final response = await _dio.patch('/donors/profile/availability', data: request.toJson());
    return DonorProfileDto.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProfile() async {
    await _dio.delete('/donors/profile');
  }
}
