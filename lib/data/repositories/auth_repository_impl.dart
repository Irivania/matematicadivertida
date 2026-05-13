import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart'; 
import '../../domain/repositories/i_auth_repository.dart';
import '../services/auth_service.dart';
import '../../core/errors/failures.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  /// Converte o User do Firebase para a nossa Entidade de Domínio (UserEntity)
  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName, // Removido o fallback fixo para usar a lógica da Entity
      fotoUrl: user.photoURL,
      // Nota: Perfil, Tipo e Pontuação costumam vir do Firestore. 
      // Se o AuthService não os provê, eles assumem os valores default da Entity.
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
  Future<UserEntity> signInWithGoogle() async {
    try {
      final UserCredential? credential = await _authService.entrarComGoogle();
      
      if (credential == null || credential.user == null) {
        throw AuthFailure("Operação cancelada pelo usuário.");
      }

      return _mapFirebaseUser(credential.user)!;
      
    } on FirebaseAuthException catch (e) {
      throw AuthFailure("Erro Firebase: ${e.code}"); 
    } catch (e) {
      debugPrint("Erro Crítico (signInWithGoogle): $e");
      throw AuthFailure("Erro inesperado ao autenticar.");
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

  /// RESOLUÇÃO DO ERRO: Assinatura compatível com a Interface IAuthRepository
  @override
  Future<void> updateProfile({
    String? displayName, 
    String? photoURL, 
    String? perfil, // Alterado para String? para manter compatibilidade genérica
    String? tipo,   // Adicionado parâmetro 'tipo' exigido pela interface
  }) async {
    try {
      // 1. Atualiza dados de identidade (Firebase Auth)
      await _authService.atualizarDadosBasicos(
        displayName: displayName,
        photoURL: photoURL,
      );

      // 2. Atualiza metadados pedagógicos (Firestore)
      if (perfil != null) {
        await _authService.atualizarPerfilUsuario(perfil);
      }
      
      // Se houver lógica específica para tipo (adulto/criança) no AuthService:
      if (tipo != null) {
        // Exemplo: await _authService.atualizarTipoUsuario(tipo);
      }
      
    } catch (e) {
      throw AuthFailure("Erro ao atualizar dados do perfil.");
    }
  }
}