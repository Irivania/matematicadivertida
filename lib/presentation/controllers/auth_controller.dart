// lib/presentation/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'progresso_game_model.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserEntity? _usuarioAtual;
  bool _isLoading = false;
  String? _perfilAtivo;
  ProgressoGameModel? _progressoAtual;

  AuthController(this._authRepository) {
    _init();
  }

  void _init() {
    _authRepository.onAuthStateChanged.listen((user) {
      _usuarioAtual = user;
      notifyListeners();
    });
  }

  // --- GETTERS NECESSÁRIOS PARA AS TELAS ---
  UserEntity? get usuarioAtual => _usuarioAtual;
  bool get isLoading => _isLoading;
  bool get estaAutenticado => _usuarioAtual != null;
  String get nomeJogador => _progressoAtual?.nomeJogador ?? '';
  String? get perfilAtivo => _perfilAtivo;

  // --- MÉTODOS CHAMADOS PELAS TELAS ---

  Future<void> loginComEmail({
    required String email, 
    required String senha, 
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    _setLoading(true);
    try {
      final user = await _authRepository.signInWithEmailAndPassword(email: email, senha: senha);
      if (user != null) {
        onSuccess();
      } else {
        onError("E-mail ou senha inválidos.");
      }
    } catch (e) {
      String msg = "Erro ao realizar login. Tente novamente.";
      final errStr = e.toString().toLowerCase();
      if (errStr.contains("user-not-found") || errStr.contains("wrong-password") || errStr.contains("invalid-credential")) {
        msg = "E-mail ou senha incorretos.";
      } else if (errStr.contains("network-request-failed")) {
        msg = "Sem conexão com a internet.";
      }
      onError(msg);
    } finally { 
      _setLoading(false); 
    }
  }

  Future<void> cadastrarComEmail({
    required String email, 
    required String senha, 
    required String nome, 
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    _setLoading(true);
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(email: email, senha: senha, nome: nome);
      if (user != null) {
        onSuccess();
      } else {
        onError("Falha ao criar conta.");
      }
    } catch (e) {
      String msg = "Erro ao cadastrar. Tente novamente.";
      final errStr = e.toString().toLowerCase();
      if (errStr.contains("email-already-in-use")) {
        msg = "Este e-mail já está cadastrado.";
      } else if (errStr.contains("weak-password")) {
        msg = "A senha é muito fraca (mínimo de 6 caracteres).";
      } else if (errStr.contains("invalid-email")) {
        msg = "O formato do e-mail é inválido.";
      }
      onError(msg);
    } finally { 
      _setLoading(false); 
    }
  }

  Future<void> recuperarSenha({
    required String email, 
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      onSuccess();
    } catch (e) {
      onError("Não foi possível enviar o e-mail de recuperação. Verifique o endereço.");
    }
  }

  Future<void> loginComGoogle({
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    _setLoading(true);
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        onSuccess();
      } else {
        onError("Login com Google cancelado.");
      }
    } catch (e) {
      onError("Erro ao autenticar com o Google.");
    } finally { 
      _setLoading(false); 
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _usuarioAtual = null;
    notifyListeners();
  }

  Future<void> escolherPerfilParaJogar({required String nome, required String perfilEscolhido}) async {
    _perfilAtivo = perfilEscolhido;
    _progressoAtual = ProgressoGameModel(
      nomeJogador: nome, 
      crianca: ProgressoPerfil(fase: 1, nivel: 1), 
      adulto: ProgressoPerfil(fase: 1, nivel: 1), 
      professor: ProgressoPerfil(fase: 1, nivel: 1)
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}