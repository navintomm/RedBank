import 'package:dio/dio.dart';
import '../domain/emergency_exceptions.dart';
import '../domain/emergency_models.dart';
import 'emergency_api_service.dart';

class EmergencyRepository {
  final EmergencyApiService _apiService;

  EmergencyRepository(this._apiService);

  Future<EmergencyRequestModel> createEmergencyRequest(CreateEmergencyRequestDto request) async {
    try {
      return await _apiService.createEmergencyRequest(request);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<EmergencyRequestModel> getEmergencyRequest(String id) async {
    try {
      return await _apiService.getEmergencyRequest(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EmergencyRequestModel>> getMyRequests() async {
    try {
      return await _apiService.getMyRequests();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelRequest(String id, String reason) async {
    try {
      await _apiService.cancelRequest(id, reason);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> acceptRequest(String id) async {
    try {
      await _apiService.acceptRequest(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> declineRequest(String id) async {
    try {
      await _apiService.declineRequest(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EmergencyRequestModel>> getActiveEmergencies() async {
    try {
      return await _apiService.getActiveEmergencies();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<EmergencyHistoryModel>> getEmergencyHistory(String id) async {
    try {
      return await _apiService.getEmergencyHistory(id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final errorMessage = error.response?.data?['message'] ?? error.message ?? 'An unknown network error occurred';

      if (statusCode == 404) {
        return EmergencyNotFoundException(errorMessage);
      } else if (statusCode == 400 || statusCode == 409) {
        // Status 409 usually for invalid transitions or conflicts
        if (errorMessage.toLowerCase().contains('expired')) {
          return RequestExpiredException(errorMessage);
        }
        return InvalidTransitionException(errorMessage);
      } else if (statusCode == 401 || statusCode == 403) {
        return AuthorizationException(errorMessage);
      }
      return EmergencyException(errorMessage, code: statusCode?.toString());
    }
    return EmergencyException(error.toString());
  }
}
