import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({required this.status, this.errorMessage});

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated() => AuthState(status: AuthStatus.authenticated);
  factory AuthState.unauthenticated() => AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String msg) => AuthState(status: AuthStatus.error, errorMessage: msg);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureTokenStorage _tokenStorage;

  AuthNotifier(this._repository, this._tokenStorage) : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    state = AuthState.loading();
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        state = AuthState.unauthenticated();
        return;
      }
      
      // Verify the token by calling getCurrentUser
      await _repository.getCurrentUser();
      state = AuthState.authenticated();
    } catch (e) {
      // If token is invalid or request fails, token refresh will be triggered by Dio interceptor.
      // If refresh also fails, Dio interceptor will clear tokens and call forceLogout.
      // We start in authenticated state to allow Dio to attempt refresh,
      // but if the initial check fails without triggering a refresh (e.g. network error), we might just stay unauthenticated.
      // Actually, let's just let the state be unauthenticated if it fails completely.
      // Wait, if we call getCurrentUser, the Dio interceptor runs. 
      // If refresh fails, interceptor clears tokens.
      final tokenAfter = await _tokenStorage.getAccessToken();
      if (tokenAfter == null) {
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated();
      }
    }
  }

  Future<void> verifyFirebaseUser(firebase.User user) async {
    state = AuthState.loading();
    try {
      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception('Failed to retrieve Firebase Token');

      final authResponse = await _repository.verifyToken(idToken);
      
      await _tokenStorage.saveTokens(
        authResponse.accessToken, 
        authResponse.refreshToken
      );

      state = AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    await _repository.logout();
    await forceLogout();
  }

  Future<void> forceLogout() async {
    await _tokenStorage.clearTokens();
    await firebase.FirebaseAuth.instance.signOut();
    state = AuthState.unauthenticated();
  }
}

final StateNotifierProvider<AuthNotifier, AuthState> authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureTokenStorageProvider),
  );
});
