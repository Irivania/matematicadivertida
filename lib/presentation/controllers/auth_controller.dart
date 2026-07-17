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
      if (user != null) onSuccess(); else onError("Falha no login");
    } catch (e) { onError(e.toString()); } 
    finally { _setLoading(false); }
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
      if (user != null) onSuccess(); else onError("Falha no cadastro");
    } catch (e) { onError(e.toString()); } 
    finally { _setLoading(false); }
  }

  Future<void> recuperarSenha({
    required String email, 
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      onSuccess();
    } catch (e) { onError(e.toString()); }
  }

  Future<void> loginComGoogle({
    required VoidCallback onSuccess, 
    required Function(String) onError
  }) async {
    _setLoading(true);
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) onSuccess(); else onError("Login cancelado");
    } catch (e) { onError(e.toString()); } 
    finally { _setLoading(false); }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _usuarioAtual = null;
    notifyListeners();
  }

  Future<void> escolherPerfilParaJogar({required String nome, required String perfilEscolhido}) async {
    _perfilAtivo = perfilEscolhido;
    _progressoAtual = ProgressoGameModel(nomeJogador: nome, crianca: ProgressoPerfil(fase: 1, nivel: 1), adulto: ProgressoPerfil(fase: 1, nivel: 1), professor: ProgressoPerfil(fase: 1, nivel: 1));
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}