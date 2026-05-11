import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Função que a tela de login vai chamar
  Future<void> realizarLogin({
    required String nome,
    required String perfil,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    // 1. Validação básica
    if (nome.trim().isEmpty) {
      onError("Por favor, digite seu nome!");
      return;
    }

    _isLoading = true;
    notifyListeners(); // Avisa a tela para mostrar um loading

    // 2. Chama o serviço de autenticação
    bool sucesso = await _authService.entrarNoJogo(nome, perfil);

    _isLoading = false;
    notifyListeners(); // Avisa a tela que terminou de carregar

    if (sucesso) {
      onSuccess();
    } else {
      onError("Ops! Algo deu errado ao conectar ao servidor.");
    }
  }
}