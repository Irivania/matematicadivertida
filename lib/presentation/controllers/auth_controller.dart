import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  UserEntity? _usuarioAtual;
  bool _isLoading = false;
  String _mensagemErro = '';

  // Construtor inicializa escutando o status de autenticação em tempo real via Stream
  AuthController(this._authRepository) {
    _escutarMudancasAutenticacao();
  }

  // Getters para a sua UI ler o estado interno com segurança
  UserEntity? get usuarioAtual => _usuarioAtual;
  bool get isLoading => _isLoading;
  String get mensagemErro => _mensagemErro;
  bool get estaAutenticado => _usuarioAtual != null;

  /// Inicializa a escuta ativa do fluxo de autenticação global do repositório
  void _escutarMudancasAutenticacao() {
    _authSubscription = _authRepository.onAuthStateChanged.listen((UserEntity? user) {
      _usuarioAtual = user;
      notifyListeners();
    });
  }

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
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Realiza a autenticação tradicional usando e-mail e senha.
  Future<void> loginComEmail({
    required String email,
    required String senha,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.trim().isEmpty || senha.trim().isEmpty) {
      onError("Por favor, preencha todos os campos.");
      return;
    }

    _iniciarLoading();
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email, 
        senha: senha,
      );
      if (user != null) {
        _pararLoading();
        onSuccess();
      } else {
        _pararLoading();
        onError("Dados inválidos de acesso.");
      }
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
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
    if (email.trim().isEmpty || senha.trim().isEmpty || nome.trim().isEmpty) {
      onError("Por favor, preencha todos os campos.");
      return;
    }

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
      final msg = _tratarErroFirebase(e);
      onError(msg);
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
      final msg = _tratarErroFirebase(e);
      onError(msg);
    }
  }

  /// Dispara o fluxo de recuperação de senha por e-mail.
  Future<void> recuperarSenha({
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (email.trim().isEmpty) {
      onError("Por favor, digite o e-mail.");
      return;
    }

    _iniciarLoading();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      _pararLoading();
      onSuccess();
    } catch (e) {
      _pararLoading();
      final msg = _tratarErroFirebase(e);
      onError(msg);
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

  /// ⚙️ Tradutor de Exceções do Firebase aprimorado para Flutter Web
  String _tratarErroFirebase(dynamic erro) {
    final erroStr = erro.toString();
    _mensagemErro = erroStr;
    debugPrint("🚨 [DEBUG AUTH] Erro cru capturado: $erroStr");

    if (erroStr.contains('email-already-in-use') || 
        erroStr.contains('account-exists-with-different-credential')) {
      return "Este e-mail já está em uso por outra conta.";
    }
    if (erroStr.contains('wrong-password') || 
        erroStr.contains('invalid-credential') || 
        erroStr.contains('invalid-password')) {
      return "Credenciais incorretas. Verifique seu e-mail e senha.";
    }
    if (erroStr.contains('user-not-found') || erroStr.contains('cannot-find-user')) {
      return "Nenhuma conta localizada com este e-mail.";
    }
    if (erroStr.contains('invalid-email')) {
      return "O formato do e-mail digitado não é válido.";
    }
    if (erroStr.contains('weak-password')) {
      return "A senha precisa ter no mínimo 6 caracteres.";
    }
    if (erroStr.contains('network-request-failed') || erroStr.contains('XMLHttpRequest')) {
      return "Falha de conexão com os servidores do Firebase. Verifique sua internet.";
    }
    if (erroStr.contains('operation-not-allowed')) {
      return "O método de autenticação por E-mail/Senha está DESATIVADO no Console do Firebase.";
    }
    if (erroStr.contains('too-many-requests')) {
      return "Muitas tentativas seguidas. Esta conta foi bloqueada temporariamente.";
    }

    return "Erro na operação: ${erroStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()}";
  }

  @override
  void dispose() {
    // Fecha a inscrição da stream ao destruir o controlador
    _authSubscription?.cancel();
    super.dispose();
  }
}