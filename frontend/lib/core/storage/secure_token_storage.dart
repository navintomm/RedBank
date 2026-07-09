// Mock implementation for secure storage using SharedPreferences or flutter_secure_storage
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

class SecureTokenStorage {
  String? _accessToken;
  String? _refreshToken;

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    // In production, use flutter_secure_storage
  }

  Future<String?> getAccessToken() async => _accessToken;
  Future<String?> getRefreshToken() async => _refreshToken;

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
