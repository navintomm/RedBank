import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_token_storage.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
    receiveTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
  ));

  final tokenStorage = ref.watch(secureTokenStorageProvider);

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401) {
        // Attempt token refresh logic here in production
        // await tokenStorage.clearTokens();
      }
      return handler.next(e);
    },
  ));

  return dio;
});
