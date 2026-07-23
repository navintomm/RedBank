import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import 'auth_models.dart';

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> verifyToken(String firebaseIdToken) async {
    try {
      final response = await _dio.post(
        '/auth/verify',
        data: {'id_token': firebaseIdToken},
      );
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to verify token');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore network errors on logout
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _dio.post(
        '/auth/fcm-token',
        data: {'fcmToken': token},
      );
    } catch (e) {
      // Ignore for now, token sync failure shouldn't crash the app
    }
  }

  Future<void> getCurrentUser() async {
    try {
      await _dio.get('/auth/me');
    } catch (e) {
      throw Exception('Failed to get current user');
    }
  }
}
