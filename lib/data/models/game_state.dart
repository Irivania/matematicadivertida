import 'package:flutter/material.dart';
import 'package:matematicadivertida/core/enums/nivel_enum.dart';
import 'package:matematicadivertida/core/config/estrutura_pedagogica.dart';
import 'package:matematicadivertida/domain/entities/game_session_entity.dart';
import 'package:matematicadivertida/domain/entities/pergunta_entity.dart';
import 'package:matematicadivertida/domain/usecases/calcular_pontuacao_use_case.dart';

class GameState extends ChangeNotifier {
  // Injeção de dependência do Caso de Uso
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  // ---------------------------------------------------
  // ESTADO DO JOGO (INTEGRADO COM ENTIDADES)
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
  // ALIASES E GETTERS (RESOLVE UI & COMPATIBILIDADE)
  // ---------------------------------------------------
  int get indicePerguntaAtual => perguntaAtual;
  String get nivel => nivelAtual.label;
  int get fase => faseAtual;
  int get pontos => xpTotal;
  
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get maxFasesPorNivel => EstruturaProgresso.fasesPorNivel;

  String get nomeNivelExibicao => "${nivelAtual.icone} ${nivelAtual.label}";
  
  // Converte o Enum Nivel para a dificuldade esperada pelo UseCase/Service
  Dificuldade get dificuldadeTecnica {
    if (nivelAtual == Nivel.bronze) return Dificuldade.facil;
    if (nivelAtual == Nivel.prata) return Dificuldade.medio;
    return Dificuldade.dificil;
  }

  String get nivelParaService => nivelAtual.name[0].toUpperCase() + nivelAtual.name.substring(1);

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO
  // ---------------------------------------------------

  void registrarAcerto({int tempoRestante = 0}) {
    acertosNaFase++;
    
    // DELEGAÇÃO: A lógica de pontos agora vem do UseCase de Domínio
    final pontosGanhos = _calcularPontuacao.executar(
      acertos: 1, // Pontuamos por acerto individual
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
    // Opcional: Implementar lógica de perda de XP por reset se desejado
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
  // PERSISTÊNCIA (MAPERS PARA FIRESTORE)
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