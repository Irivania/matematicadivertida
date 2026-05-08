import '../enums/nivel_enum.dart';

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

/// Estrutura pedagógica por ano escolar.
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
class EstruturaProgresso {
  static const int fasesPorNivel = 10;
  static const int perguntasPorFase = 10;

  static const int perguntasPorNivel = fasesPorNivel * perguntasPorFase; // 100
  static final int perguntasTotal = perguntasPorNivel * Nivel.values.length; // 500
}