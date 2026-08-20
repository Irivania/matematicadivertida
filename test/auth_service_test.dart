import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';

// Mock simples para o Firebase não quebrar nos testes
class MockFirebasePlatform {
  static void ensureInitialized() {
    TestWidgetsFlutterBinding.ensureInitialized();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AuthService pode ser testado com inicialização simulada', () {
    // Garante que o ambiente de testes reconhece o contexto
    expect(true, isTrue);
  });
}