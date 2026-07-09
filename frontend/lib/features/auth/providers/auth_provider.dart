import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../core/storage/secure_token_storage.dart';
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

  AuthNotifier(this._repository, this._tokenStorage) : super(AuthState.initial());

  Future<void> verifyFirebaseUser(firebase.User user) async {
    state = AuthState.loading();
    try {
      final idToken = await user.getIdToken();
      if (idToken == null) throw Exception("Failed to retrieve Firebase Token");

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
    await _tokenStorage.clearTokens();
    await firebase.FirebaseAuth.instance.signOut();
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureTokenStorageProvider),
  );
});
