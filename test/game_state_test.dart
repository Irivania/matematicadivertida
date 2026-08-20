import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matematicadivertida/data/models/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameState - Testes Unitários de Funções Auxiliares', () {
    test('Deve formatar segundos corretamente em formato de minutos (MM:SS)', () async {
      final gameState = GameState();

      expect(gameState.formatarMinutos(0), equals("00:00"));
      expect(gameState.formatarMinutos(45), equals("00:45"));
      expect(gameState.formatarMinutos(60), equals("01:00"));
      expect(gameState.formatarMinutos(90), equals("01:30"));
    });

    test('Deve normalizar respostas faladas removendo pontuações', () {
      final gameState = GameState();

      String textoOriginal = "Mundo 123.";
      String textoNormalizado = gameState.normalizarRespostaFalada(textoOriginal);
      
      expect(textoNormalizado.contains("mundo 123"), isTrue);
    });

    // --- NOVO TESTE ADICIONADO AQUI ---
    test('Deve retornar string vazia ou status correto para medalhas quando o nível não for concluído', () {
      final gameState = GameState();

      // Um nível que o usuário nunca jogou não deve ter medalha registrada inicialmente
      String medalhaNivelInexistente = gameState.obterTipoMedalha('nivel_fantasma');
      
      expect(medalhaNivelInexistente, isEmpty);
    });
  });
}