// lib/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:matematicadivertida/domain/entities/app_user.dart'; // Criar esta entidade
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/core/errors/failures.dart'; // Para tratamento global

class AuthRepositoryImpl implements IAuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  /// Converte o User do Firebase para a nossa Entidade de Domínio (Pureza)
  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> get userState => 
      _authService.usuarioStatus.map(_mapFirebaseUser);

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final UserCredential? credential = await _authService.entrarComGoogle();
      
      if (credential == null || credential.user == null) {
        throw AuthFailure(message: "Operação cancelada pelo usuário.");
      }

      // Validação de Segurança: Zero Trust
      final user = credential.user!;
      return _mapFirebaseUser(user)!;
      
    } on FirebaseAuthException catch (e) {
      // Mapeamento de erros específicos para o domínio
      throw AuthFailure.fromFirebase(e.code);
    } catch (e) {
      debugPrint("Erro Crítico (signInWithGoogle): $e");
      throw AuthFailure(message: "Erro inesperado ao autenticar.");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.sair();
    } catch (e) {
      debugPrint("Erro ao deslogar: $e");
      throw AuthFailure(message: "Falha ao encerrar sessão de forma segura.");
    }
  }

  @override
  Future<void> updateProfileRole(String role) async {
    try {
      // Sanitização de entrada antes de enviar para o serviço
      final sanitizedRole = role.trim().toLowerCase();
      await _authService.atualizarPerfilUsuario(sanitizedRole);
    } catch (e) {
      debugPrint("Erro ao atualizar perfil: $e");
      throw AuthFailure(message: "Não foi possível salvar as preferências de perfil.");
    }
  }
}