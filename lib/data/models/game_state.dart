import 'package:flutter/material.dart';
import '../../domain/usecases/calcular_pontuacao_usecase.dart';
import '../../core/enums/nivel_enum.dart';
import '../../core/config/estrutura_pedagogica.dart';

/// Gerencia o estado reativo do progresso do jogador durante uma sessão.
class GameState extends ChangeNotifier {
  // Injeção do Caso de Uso de Domínio
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  // ---------------------------------------------------
  // ESTADO DO JOGO (TREINO / BASE)
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
  // ESTADO DO MODO DISPUTA (NOVO)
  // ---------------------------------------------------
  /// Guarda o menor tempo (em segundos) que o jogador levou para completar 
  /// TODAS as perguntas de um nível específico.
  /// Chave: Nome do nível (String), Valor: Tempo em segundos (int).
  final Map<String, int> _recordesTempoPorNivel = {};

  // ---------------------------------------------------
  // GETTERS DE COMPATIBILIDADE E UI
  // ---------------------------------------------------
  
  int get acertos => acertosNaFase;
  String get nivelParaService => nivelAtual.name;
  int get indicePerguntaAtual => perguntaAtual;
  String get nivel => nivelAtual.label;
  int get fase => faseAtual;
  int get pontos => xpTotal;
  
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get maxFasesPorNivel => EstruturaProgresso.fasesPorNivel;

  String get nomeNivelExibicao => "${nivelAtual.icone} ${nivelAtual.label}";
  
  Dificuldade get diculdadeTecnica {
    if (nivelAtual == Nivel.bronze) return Dificuldade.facil;
    if (nivelAtual == Nivel.prata) return Dificuldade.medio;
    return Dificuldade.dificil;
  }

  // ---------------------------------------------------
  // LÓGICA DO MODO DISPUTA (RECORDES E VELOCIDADE)
  // ---------------------------------------------------

  /// Recupera o melhor tempo registrado de um nível específico.
  /// Retorna `null` caso o jogador ainda não tenha completado este nível na disputa.
  int? obterRecordeDesteNivel(Nivel nivel) => _recordesTempoPorNivel[nivel.name];

  /// Calcula a soma de todos os melhores tempos do jogador (Pontuação do Ranking Final).
  int get tempoTotalDisputaCombinado => _recordesTempoPorNivel.values.fold(0, (total, t) => total + t);

  /// Verifica se o tempo feito pelo jogador é menor que o recorde anterior dele.
  /// Se for menor, atualiza localmente e retorna [true] para sinalizar o recorde na UI.
  bool verificarESalvarRecordeDesteNivel(Nivel nivel, int segundosGasto) {
    final int? tempoAntigo = _recordesTempoPorNivel[nivel.name];

    if (tempoAntigo == null || segundosGasto < tempoAntigo) {
      _recordesTempoPorNivel[nivel.name] = segundosGasto;
      notifyListeners();
      return true; // Bateu o próprio recorde!
    }
    return false; // Fez o percurso, mas foi mais lento que seu melhor tempo
  }

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO (MODIFICADOS)
  // ---------------------------------------------------

  void registrarAcerto({int tempoRestante = 0}) {
    acertosNaFase++;
    
    final int pontosGanhos = _calcularPontuacao.executar(
      acertos: 1,
      dificuldade: diculdadeTecnica,
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
  // PERSISTÊNCIA (INTEGRADO COM FIRESTORE)
  // ---------------------------------------------------
  
  Map<String, dynamic> toMap() {
    return {
      'fase_atual': faseAtual,
      'xp_total': xpTotal,
      'nivel_atual': nivelAtual.name,
      'perfil_usuario': perfil,
      'recordes_disputa': _recordesTempoPorNivel, // Mapeia os recordes para salvar em nuvem
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

    // Recupera os tempos salvos do banco convertendo de dynamic de forma segura
    if (map['recordes_disputa'] != null) {
      _recordesTempoPorNivel.clear();
      (map['recordes_disputa'] as Map<String, dynamic>).forEach((key, value) {
        _recordesTempoPorNivel[key] = value as int;
      });
    }
    
    notifyListeners();
  }
}