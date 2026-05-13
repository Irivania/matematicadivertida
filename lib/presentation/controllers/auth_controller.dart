import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    notifyListeners(); 

    try {
      // 2. CORREÇÃO: Chamamos o método sem argumentos, conforme definido no seu AuthService
      final userCredential = await _authService.entrarNoJogo();

      // 3. CORREÇÃO: Verificamos se o retorno não é nulo (o que indica sucesso no Firebase)
      if (userCredential != null && userCredential.user != null) {
        
        // 4. OPCIONAL: Se quiser salvar o nome e perfil digitados no Firestore logo após o login
        await _authService.atualizarPerfilUsuario(perfil); 
        // Nota: Você pode precisar ajustar o AuthService para salvar o 'nome' também se desejar.

        _isLoading = false;
        notifyListeners(); 
        onSuccess();
      } else {
        _isLoading = false;
        notifyListeners(); 
        onError("Ops! Algo deu errado ao conectar ao servidor.");
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError("Erro inesperado: $e");
    }
  }
}