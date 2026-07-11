import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../domain/donor_models.dart';
import 'donor_api_service.dart';

final donorApiServiceProvider = Provider<DonorApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return DonorApiService(dio);
});

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  final apiService = ref.watch(donorApiServiceProvider);
  return DonorRepository(apiService);
});

class DonorRepository {
  final DonorApiService _apiService;

  DonorRepository(this._apiService);

  Future<DonorProfileDto> getProfile() async {
    try {
      return await _apiService.getProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw DonorNotFoundException(e.response?.data['message'] ?? 'Profile not found');
      }
      throw _handleException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<DonorProfileDto> createOrUpdateProfile(UpdateDonorProfileRequest request) async {
    try {
      return await _apiService.createOrUpdateProfile(request);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<DonorProfileDto> updateAvailability(UpdateAvailabilityRequest request) async {
    try {
      return await _apiService.updateAvailability(request);
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _apiService.deleteProfile();
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(DioException e) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? 'An error occurred';
      return DonorServerException(message);
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}

class DonorNotFoundException implements Exception {
  final String message;
  DonorNotFoundException(this.message);
  
  @override
  String toString() => message;
}

class DonorServerException implements Exception {
  final String message;
  DonorServerException(this.message);
  
  @override
  String toString() => message;
}
