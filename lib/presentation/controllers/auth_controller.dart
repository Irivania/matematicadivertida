import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;

  UserEntity? _usuarioAtual;
  bool _isLoading = false;
  String _mensagemErro = '';

  // Construtor inicializa escutando o status do Firebase em tempo real
  AuthController(this._authRepository) {
    _authRepository.onAuthStateChanged.listen((UserEntity? user) {
      _usuarioAtual = user;
      notifyListeners();
    });
  }

  // Getters para a sua UI ler o estado interno com segurança
  UserEntity? get usuarioAtual => _usuarioAtual;
  bool get isLoading => _isLoading;
  String get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _usuarioAtual != null;

  /// Método principal de login/entrada rápida (Modo Convidado com Setup de Perfil)
  Future<void> realizarLogin({
    required String nome,
    required String perfil,
    required String tipo, 
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (nome.trim().isEmpty) {
      onError("Por favor, digite seu nome!");
      return;
    }

    _iniciarLoading(); 

    try {
      final usuario = await _authRepository.signInAnonymously();

      if (usuario != null) {
        // Atualiza a ficha cadastral pedagógica do usuário
        await _authRepository.updateProfile(
          displayName: nome,
          perfil: perfil,
          tipo: tipo,
        );

        _pararLoading(); 
        onSuccess();
      } else {
        _pararLoading(); 
        onError("Não foi possível iniciar a sessão temporária.");
      }
    } catch (e) {
      _pararLoading();
      onError("Erro ao entrar: $e");
    }
  }

  /// Realiza a autenticação tradicional usando e-mail e senha.
  Future<void> loginComEmail({
    required String email,
    required String senha,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _iniciarLoading();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(email: email, senha: senha);
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("Dados inválidos de acesso.");
      }
    } catch (e) {
      _pararLoading();
      onError(e.toString());
    }
  }

  /// Cadastra uma nova conta de Primeiro Acesso por e-mail e senha.
  Future<void> cadastrarComEmail({
    required String email,
    required String senha,
    required String nome,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _iniciarLoading();
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        senha: senha,
        nome: nome,
      );
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("Não foi possível criar o registro da conta.");
      }
    } catch (e) {
      _pararLoading();
      onError(e.toString());
    }
  }

  /// Realiza a autenticação direta de um clique via Google Sign-In.
  Future<void> loginComGoogle({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _iniciarLoading();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("A autenticação com o Google foi cancelada.");
      }
    } catch (e) {
      _pararLoading();
      onError(e.toString());
    }
  }

  /// Dispara o fluxo de recuperação de senha por e-mail.
  Future<void> recuperarSenha({
    required String email,
    required String onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Encerra a sessão atual de forma limpa e notifica a UI para voltar ao login.
  Future<void> logout() async {
    _iniciarLoading();
    try {
      await _authRepository.signOut();
      _usuarioAtual = null; // Garante a limpeza local imediata
    } catch (e) {
      debugPrint("Erro interno durante o logout: $e");
    } finally {
      _pararLoading(); // Dispara o notifyListeners() que redesenha as telas
    }
  }

  void _iniciarLoading() {
    _isLoading = true;
    _mensagemErro = '';
    notifyListeners();
  }

  void _pararLoading() {
    _isLoading = false;
    notifyListeners();
  }
}