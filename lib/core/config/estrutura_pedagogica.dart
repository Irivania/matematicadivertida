import 'package:matematicadivertida/core/enums/nivel_enum.dart';

/// Enum representando os anos escolares do 1º ao 5º ano.
enum AnoEscolar {
  primeiro,
  segundo,
  terceiro,
  quarto,
  quinto,
}

/// Mapeamento dos níveis do jogo para o ano escolar predominante.
const Map<Nivel, AnoEscolar> nivelParaAnoEscolar = {
  Nivel.bronze: AnoEscolar.primeiro,   // 1º ano
  Nivel.prata: AnoEscolar.segundo,     // 2º ano
  Nivel.ouro: AnoEscolar.terceiro,     // 3º ano
  Nivel.platina: AnoEscolar.quarto,    // 4º ano
  Nivel.mestre: AnoEscolar.quinto,     // 5º ano
};

/// Estrutura pedagógica por ano escolar com os conteúdos da BNCC.
const Map<AnoEscolar, List<String>> conteudoPorAno = {
  AnoEscolar.primeiro: [
    'Números até 20',
    'Adição simples',
    'Subtração simples',
  ],
  AnoEscolar.segundo: [
    'Números até 100',
    'Adição e subtração maiores',
    'Introdução à multiplicação',
  ],
  AnoEscolar.terceiro: [
    'Multiplicação',
    'Divisão simples',
    'Problemas básicos',
  ],
  AnoEscolar.quarto: [
    'Divisão mais complexa',
    'Problemas com interpretação',
    'Introdução a fração',
  ],
  AnoEscolar.quinto: [
    'Frações',
    'Porcentagem',
    'Problemas completos (estilo prova)',
  ],
};

/// Estrutura de progressão do jogo.
/// 
/// Centraliza as regras de negócio sobre a quantidade de questões.
class EstruturaProgresso {
  static const int fasesPorNivel = 10;
  static const int perguntasPorFase = 10;

  /// Quantidade de perguntas para completar um nível inteiro (100).
  static const int perguntasPorNivel = fasesPorNivel * perguntasPorFase;

  /// CORREÇÃO: Para evitar o erro 'const_initialized_with_non_constant_value',
  /// definimos o total multiplicando pelo número fixo de níveis (5).
  /// Total: 500 perguntas no jogo.
  static const int perguntasTotal = perguntasPorNivel * 5; 
}