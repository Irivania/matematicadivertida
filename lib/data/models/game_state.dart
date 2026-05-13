import 'package:flutter/material.dart';
import '../../domain/usecases/calcular_pontuacao_usecase.dart';
import '../../core/enums/nivel_enum.dart';
import '../../core/config/estrutura_pedagogica.dart';

/// Gerencia o estado reativo do progresso do jogador durante uma sessão.
class GameState extends ChangeNotifier {
  // Injeção do Caso de Uso de Domínio
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  // ---------------------------------------------------
  // ESTADO DO JOGO
  // ---------------------------------------------------
  int faseAtual = 1;
  int perguntaAtual = 1; 
  int xpTotal = 0; 
  int acertosNaFase = 0;
  int errosNaFase = 0;
  int vidas = 3; 
  Nivel nivelAtual = Nivel.bronze;
  String perfil = "crianca";

  // ---------------------------------------------------
  // GETTERS DE COMPATIBILIDADE E UI
  // ---------------------------------------------------
  
  /// Atalho para UI que busca 'acertos' (Corrige erro no GameHUD)
  int get acertos => acertosNaFase;

  /// Retorna o nome técnico do nível (Corrige erro na JogoScreen)
  String get nivelParaService => nivelAtual.name;

  int get indicePerguntaAtual => perguntaAtual;
  String get nivel => nivelAtual.label;
  int get fase => faseAtual;
  int get pontos => xpTotal;
  
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get maxFasesPorNivel => EstruturaProgresso.fasesPorNivel;

  String get nomeNivelExibicao => "${nivelAtual.icone} ${nivelAtual.label}";
  
  /// Converte o Enum Nivel para a dificuldade técnica processada pelo UseCase.
  Dificuldade get dificuldadeTecnica {
    if (nivelAtual == Nivel.bronze) return Dificuldade.facil;
    if (nivelAtual == Nivel.prata) return Dificuldade.medio;
    return Dificuldade.dificil;
  }

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO
  // ---------------------------------------------------

  void registrarAcerto({int tempoRestante = 0}) {
    acertosNaFase++;
    
    // O retorno do UseCase já é int conforme a última correção
    final int pontosGanhos = _calcularPontuacao.executar(
      acertos: 1,
      dificuldade: dificuldadeTecnica,
      tempoRestante: tempoRestante,
    );
    
    xpTotal += pontosGanhos;
    notifyListeners(); 
  }

  void registrarErro() {
    errosNaFase++;
    if (vidas > 0) vidas--;
    notifyListeners();
  }

  void avancarPergunta() {
    if (perguntaAtual < maxPerguntasPorFase) {
      perguntaAtual++;
      notifyListeners();
    }
  }

  void resetFase() {
    perguntaAtual = 1;
    acertosNaFase = 0;
    errosNaFase = 0;
    vidas = 3;
    notifyListeners();
  }

  void concluirEAvancarFase() {
    if (faseAtual < maxFasesPorNivel) {
      faseAtual++;
    } else {
      _subirNivel();
      faseAtual = 1;
    }
    resetFase();
  }

  void _subirNivel() {
    nivelAtual = switch (nivelAtual) {
      Nivel.bronze  => Nivel.prata,
      Nivel.prata   => Nivel.ouro,
      Nivel.ouro    => Nivel.platina,
      Nivel.platina => Nivel.mestre,
      _             => Nivel.mestre,
    };
  }

  void resetJogo() {
    faseAtual = 1;
    perguntaAtual = 1;
    xpTotal = 0;
    acertosNaFase = 0;
    errosNaFase = 0;
    vidas = 3;
    nivelAtual = Nivel.bronze;
    notifyListeners();
  }

  // ---------------------------------------------------
  // PERSISTÊNCIA (MAPPERS PARA FIRESTORE)
  // ---------------------------------------------------
  
  Map<String, dynamic> toMap() {
    return {
      'fase_atual': faseAtual,
      'xp_total': xpTotal,
      'nivel_atual': nivelAtual.name,
      'perfil_usuario': perfil,
      'ultima_atualizacao': DateTime.now().toIso8601String(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    faseAtual = map['fase_atual'] ?? 1;
    xpTotal = map['xp_total'] ?? 0;
    perfil = map['perfil_usuario'] ?? "crianca";
    
    nivelAtual = Nivel.values.firstWhere(
      (e) => e.name == map['nivel_atual'], 
      orElse: () => Nivel.bronze
    );
    
    notifyListeners();
  }
}