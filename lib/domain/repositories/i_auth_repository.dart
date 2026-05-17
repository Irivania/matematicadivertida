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
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? perfil, // Ex: 'crianca', 'adulto'
    String? tipo,   // Ex: 'aluno', 'professor'
  });

  /// Deleta a conta do usuário e seus dados associados (Regra de Compliance/LGPD).
  Future<void> deleteAccount();

  // =========================================================================
  // NOVOS MÉTODOS: FLUXO DE E-MAIL E SENHA (AUTENTICAÇÃO HÍBRIDA)
  // =========================================================================

  /// Realiza a autenticação de um usuário existente utilizando E-mail e Senha.
  /// 
  /// Dispara um `AuthFailure` caso as credenciais sejam inválidas.
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String senha,
  });

  /// Registra um novo usuário no sistema criando uma conta com E-mail e Senha.
  /// 
  /// [nome] será utilizado para o preenchimento inicial do `displayName`.
  Future<UserEntity?> signUpWithEmailAndPassword({
    required String email,
    required String senha,
    required String nome,
  });

  /// Envia um link de redefinição de acesso para o e-mail informado.
  /// 
  /// Essencial para a funcionalidade de "Esqueci minha senha".
  Future<void> sendPasswordResetEmail({
    required String email,
  });
}