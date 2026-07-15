import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart'; 
import '../../domain/repositories/i_auth_repository.dart';
import '../services/auth_service.dart';
import '../../core/errors/failures.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  /// Converte o User nativo do Firebase para a nossa Entidade de Domínio (UserEntity)
  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      fotoUrl: user.photoURL,
    );
  }

  @override
  UserEntity? get currentUser => _mapFirebaseUser(_authService.usuarioAtual);

  @override
  Stream<UserEntity?> get onAuthStateChanged => 
      _authService.usuarioStatus.map(_mapFirebaseUser);

  @override
  Future<UserEntity?> signInAnonymously() async {
    try {
      final user = await _authService.entrarAnonimamente();
      return _mapFirebaseUser(user);
    } catch (e) {
      throw AuthFailure("Erro ao entrar como convidado.");
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final UserCredential? credential = await _authService.entrarComGoogle();
      
      if (credential == null || credential.user == null) {
        throw AuthFailure("Operação cancelada pelo usuário.");
      }

      return _mapFirebaseUser(credential.user);
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-signin-token-error' || e.code == 'google-signin-error') {
        throw AuthFailure(
          'Não foi possível concluir o login com o Google. Verifique a configuração do Firebase e do Google Cloud Console.',
        );
      }
      throw AuthFailure("Erro Firebase: ${e.code}");
    } catch (e) {
      debugPrint("Erro Crítico (signInWithGoogle): $e");
      throw AuthFailure("Erro inesperado ao autenticar com Google.");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.sair();
    } catch (e) {
      throw AuthFailure("Falha ao encerrar sessão.");
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _authService.excluirConta();
    } catch (e) {
      throw AuthFailure("Não foi possível excluir a conta.");
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName, 
    String? photoURL, 
    String? perfil, 
    String? tipo,   
  }) async {
    try {
      await _authService.atualizarDadosBasicos(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (perfil != null) {
        await _authService.atualizarPerfilUsuario(perfil);
      }
      
      // Se o seu fluxo pedagógico exigir salvar o 'tipo' (ex: Professor/Aluno),
      // você pode chamar uma rota do Firestore ou serviço dedicado aqui abaixo:
      // if (tipo != null) { await _firestoreService.salvarTipo(tipo); }

    } catch (e) {
      throw AuthFailure("Erro ao atualizar dados do perfil.");
    }
  }

  // =========================================================================
  // IMPLEMENTAÇÃO DOS MÉTODOS DE AUTENTICAÇÃO HÍBRIDA (E-MAIL/SENHA)
  // =========================================================================

  @override
  Future<UserEntity?> signInWithEmailAndPassword({
    required String email,
    required String senha,
  }) async {
    try {
      final user = await _authService.entrarComEmailESenha(email, senha);
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential': // Novo código unificado do Firebase Auth para credenciais erradas
          throw AuthFailure("E-mail não cadastrado ou senha incorreta.");
        case 'wrong-password':
          throw AuthFailure("Senha incorreta.");
        case 'invalid-email':
          throw AuthFailure("O formato do e-mail digitado é inválido.");
        case 'user-disabled':
          throw AuthFailure("Este usuário foi desativado temporariamente.");
        default:
          throw AuthFailure("Erro ao realizar login: ${e.message}");
      }
    } catch (e) {
      // Fallback inteligente caso a exceção venha envelopada como String (comum em compilações Web)
      final erroStr = e.toString();
      if (erroStr.contains('invalid-credential') || erroStr.contains('wrong-password')) {
        throw AuthFailure("E-mail ou senha incorretos.");
      }
      throw AuthFailure("Não foi possível conectar ao servidor de autenticação.");
    }
  }

  @override
  Future<UserEntity?> signUpWithEmailAndPassword({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      // 1. Cria a credencial de e-mail e senha no Firebase Auth
      final user = await _authService.cadastrarComEmailESenha(email, senha);
      
      if (user != null) {
        // 2. Atualiza imediatamente o nome informado na ficha de cadastro
        await _authService.atualizarDadosBasicos(displayName: nome);
        
        // Reload necessário para garantir que o token local aplique o displayName criado
        await user.reload();
        final usuarioAtualizado = _authService.usuarioAtual;
        
        return _mapFirebaseUser(usuarioAtualizado);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthFailure("Este e-mail já está sendo utilizado por outra conta.");
        case 'weak-password':
          throw AuthFailure("A senha informada é muito fraca. Digite pelo menos 6 caracteres.");
        case 'invalid-email':
          throw AuthFailure("O e-mail digitado é inválido.");
        default:
          throw AuthFailure("Erro ao criar conta: ${e.message}");
      }
    } catch (e) {
      final erroStr = e.toString();
      if (erroStr.contains('email-already-in-use')) {
        throw AuthFailure("Este e-mail já está em uso.");
      }
      throw AuthFailure("Falha crítica ao criar registro de usuário.");
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.enviarEmailRecuperacao(email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw AuthFailure("O formato do e-mail informado é inválido.");
      }
      throw AuthFailure("Não conseguimos processar o envio. Verifique os dados e tente novamente.");
    } catch (e) {
      throw AuthFailure("Erro inesperado ao solicitar redefinição.");
    }
  }
}