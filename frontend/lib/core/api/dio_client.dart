import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_token_storage.dart';
import '../constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
    receiveTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
  ));

  final tokenStorage = ref.watch(secureTokenStorageProvider);

  Future<void>? refreshTask;

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // If a refresh is ongoing, wait for it to finish before proceeding
      if (refreshTask != null) {
        await refreshTask;
      }
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      // Handle Unauthorized (Token Expiration)
      if (e.response?.statusCode == 401) {
        final refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken != null) {
          if (refreshTask == null) {
            // Start the refresh process
            refreshTask = () async {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
                final refreshResponse = await refreshDio.post('/auth/refresh', data: {
                  'refreshToken': refreshToken,
                });

                if (refreshResponse.statusCode == 200) {
                  final newAccessToken = refreshResponse.data['data']['accessToken'];
                  final newRefreshToken = refreshResponse.data['data']['refreshToken'];
                  await tokenStorage.saveTokens(newAccessToken, newRefreshToken);
                } else {
                  throw Exception('Refresh failed');
                }
              } catch (refreshError) {
                // Refresh failed completely
                ref.read(authProvider.notifier).forceLogout();
                rethrow;
              } finally {
                refreshTask = null; // Clear task when done
              }
            }();
          }

          try {
            await refreshTask;
            // Retry original request with new token
            final newAccessToken = await tokenStorage.getAccessToken();
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final cloneReq = await dio.fetch(options);
            return handler.resolve(cloneReq);
          } catch (retryError) {
            return handler.next(e);
          }
        } else {
          ref.read(authProvider.notifier).forceLogout();
        }
      }
      return handler.next(e);
    },
  ));

  // Network Retry Interceptor for transient errors (500, 502, 503, 504) or timeouts
  dio.interceptors.add(InterceptorsWrapper(
    onError: (DioException e, handler) async {
      if (_shouldRetry(e)) {
        int retries = e.requestOptions.extra['retries'] ?? 0;
        if (retries < 3) {
          e.requestOptions.extra['retries'] = retries + 1;
          await Future.delayed(Duration(seconds: 1 * (retries + 1))); // Exponential backoff
          try {
            final cloneReq = await dio.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          } catch (retryError) {
            return handler.next(retryError as DioException);
          }
        }
      }
      return handler.next(e);
    }
  ));

  return dio;
});

bool _shouldRetry(DioException e) {
  return e.type == DioExceptionType.connectionTimeout ||
         e.type == DioExceptionType.receiveTimeout ||
         e.type == DioExceptionType.connectionError ||
         (e.response != null && e.response!.statusCode! >= 500);
}
