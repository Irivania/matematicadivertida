// lib/domain/repositories/i_auth_repository.dart

import '../entities/user_entity.dart';

/// Interface de Autenticação (Contrato de Domínio).
/// 
/// Em 2026, as interfaces de domínio NÃO devem conhecer pacotes de terceiros
/// como FirebaseAuth ou GoogleSignIn. Elas operam apenas com nossas Entities.
abstract class IAuthRepository {
  
  /// Stream que notifica mudanças no estado do usuário.
  /// Retorna [UserEntity] em vez de classes do Firebase.
  Stream<UserEntity?> get onAuthStateChanged;

  /// Retorna o usuário que está logado no momento.
  UserEntity? get currentUser;

  /// Realiza o login via Google e retorna a entidade do usuário.
  /// Lança [AuthException] em caso de falha.
  Future<UserEntity?> signInWithGoogle();

  /// Realiza login anônimo para modo de jogo rápido.
  Future<UserEntity?> signInAnonymously();

  /// Finaliza a sessão atual.
  Future<void> signOut();

  /// Atualiza o perfil (aluno/professor) e o tipo (criança/adulto).
  /// Agora usa tipos fortes definidos na UserEntity.
  Future<void> updateProfile({
    required PerfilUsuario perfil,
    required TipoUsuario tipo,
  });

  /// Deleta a conta do usuário (Requisito LGPD/GDPR 2026).
  Future<void> deleteAccount();
}