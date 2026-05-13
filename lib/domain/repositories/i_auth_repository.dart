import '../entities/user_entity.dart';

/// Interface de Autenticação (Contrato de Domínio).
/// 
/// Seguindo o Clean Architecture, esta interface define O QUE o sistema faz,
/// sem depender de COMO (Firebase, Supabase, etc) é feito.
abstract class IAuthRepository {
  
  /// Stream que notifica mudanças no estado do usuário.
  /// Transforma User do Firebase em [UserEntity] da nossa camada de domínio.
  Stream<UserEntity?> get onAuthStateChanged;

  /// Retorna o usuário que está logado no momento.
  UserEntity? get currentUser;

  /// Realiza o login via Google.
  Future<UserEntity?> signInWithGoogle();

  /// Realiza login anônimo para permitir que o usuário teste o jogo.
  Future<UserEntity?> signInAnonymously();

  /// Finaliza a sessão do usuário no Firebase e no Google Sign-In.
  Future<void> signOut();

  /// Atualiza os dados de perfil do usuário no Firestore.
  /// 
  /// CORREÇÃO: Parâmetros tornados opcionais com chaves {} para bater com a 
  /// implementação e permitir atualizações parciais.
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? perfil, // Ex: 'crianca', 'adulto'
    String? tipo,   // Ex: 'aluno', 'professor'
  });

  /// Deleta a conta do usuário e seus dados associados (LGPD).
  Future<void> deleteAccount();
}