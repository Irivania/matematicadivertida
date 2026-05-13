import 'package:flutter/material.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository);
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Método principal de login/entrada
  Future<void> realizarLogin({
    required String nome,
    required String perfil,
    required String tipo, // Adicionado para suportar a nova estrutura
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    // 1. Validação básica de UI
    if (nome.trim().isEmpty) {
      onError("Por favor, digite seu nome!");
      return;
    }

    _isLoading = true;
    notifyListeners(); 

    try {
      // 2. CORREÇÃO: Usamos 'signInAnonymously' ou 'signInWithGoogle' do Repositório.
      // O método 'entrarNoJogo' era um nome genérico que causava o erro.
      final usuario = await _authRepository.signInAnonymously();

      if (usuario != null) {
        // 3. ATUALIZAÇÃO DE PERFIL: Salva o nome, perfil e tipo escolhidos
        // Agora usando a assinatura correta que definimos no AuthRepositoryImpl
        await _authRepository.updateProfile(
          displayName: nome,
          perfil: perfil,
          tipo: tipo,
        );

        _isLoading = false;
        notifyListeners(); 
        onSuccess();
      } else {
        _isLoading = false;
        notifyListeners(); 
        onError("Não foi possível iniciar a sessão.");
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError("Erro ao entrar: $e");
    }
  }

  /// Método para deslogar
  Future<void> logout() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}