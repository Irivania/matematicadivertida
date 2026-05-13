import 'package:flutter/foundation.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';

/// Implementação do repositório de autenticação.
/// 
/// Esta classe atua como um adaptador entre a definição do domínio (IAuthRepository)
/// e o serviço concreto de infraestrutura (AuthService).
class AuthRepositoryImpl implements IAuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<User?> get userState => _authService.usuarioStatus;

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final UserCredential? credential = await _authService.entrarComGoogle();
      return credential;
    } catch (e) {
      // O debugPrint é preferível ao print comum pois não descarta linhas no log do Android
      debugPrint("Erro no Repositório de Autenticação (signInWithGoogle): $e");
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.sair();
    } catch (e) {
      debugPrint("Erro ao deslogar: $e");
    }
  }

  @override
  Future<void> updateProfileRole(String role) async {
    try {
      await _authService.atualizarPerfilUsuario(role);
    } catch (e) {
      debugPrint("Erro ao atualizar perfil (role): $e");
    }
  }
}