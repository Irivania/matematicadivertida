// CORREÇÃO: Usando caminho absoluto para garantir que o compilador encontre as constantes
import 'package:matematicadivertida/core/config/estrutura_pedagogica.dart';

class GameConfig {
  // Se EstruturaProgresso tiver as variáveis como 'static const', este código funciona.
  // Se o erro persistir, altere de 'static const' para 'static final'.
  
  static const int perguntasPorFase = EstruturaProgresso.perguntasPorFase;
  static const int fasesPorNivel = EstruturaProgresso.fasesPorNivel;
  static const int perguntasPorNivel = EstruturaProgresso.perguntasPorNivel;
  static const int perguntasTotal = EstruturaProgresso.perguntasTotal;
}