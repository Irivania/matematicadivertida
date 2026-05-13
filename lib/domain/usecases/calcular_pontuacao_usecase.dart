// lib/domain/usecases/calcular_pontuacao_use_case.dart

import '../entities/pergunta_entity.dart';

/// Caso de Uso responsável pela lógica de gamificação.
/// 
/// Em 2026, centralizamos o cálculo de XP aqui para que mudanças na 
/// economia do jogo não afetem os Controllers ou Repositórios.
class CalcularPontuacaoUseCase {
  
  /// Executa o cálculo de pontos baseado no desempenho da rodada.
  /// 
  /// [acertos]: Quantidade de questões corretas.
  /// [dificuldade]: O nível da questão (Enum) para aplicar o multiplicador.
  /// [tempoRestante]: Bônus opcional por rapidez (UX Gamificada).
  int executar({
    required int acertos,
    required Dificuldade dificuldade,
    int tempoRestante = 0,
  }) {
    if (acertos <= 0) return 0;

    // 1. Definição do valor base por acerto
    const int pontosPorAcerto = 10;
    int pontuacaoBase = acertos * pontosPorAcerto;

    // 2. Aplicação do Multiplicador de Dificuldade (Elimina Strings Mágicas)
    double multiplicador;
    switch (dificuldade) {
      case Dificuldade.facil:
        multiplicador = 1.0;
        break;
      case Dificuldade.medio:
        multiplicador = 1.5;
        break;
      case Dificuldade.dificil:
        multiplicador = 2.0;
        break;
    }

    // 3. Cálculo do Bônus de Tempo (Incentivo à agilidade)
    // Ex: 1 ponto extra para cada 5 segundos restantes
    int bonusVelocidade = (tempoRestante / 5).floor();

    // 4. Resultado Final
    final resultadoFinal = (pontuacaoBase * multiplicador).toInt() + bonusVelocidade;

    return resultadoFinal;
  }
}