// lib/data/models/game_state.dart

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
  // ESTADO DE ACESSIBILIDADE
  // ---------------------------------------------------
  bool acessibilidadeVoz = false;

  void alternarAcessibilidadeVoz() {
    acessibilidadeVoz = !acessibilidadeVoz;
    notifyListeners();
  }

  // ---------------------------------------------------
  // ESTADO DO MODO DISPUTA
  // ---------------------------------------------------
  final Map<String, int> _recordesTempoPorNivel = {};
  
  // Novo mapa para salvar as datas em que os recordes foram batidos
  final Map<String, String> _datasRecordesPorNivel = {};
  
  int _tempoAcumuladoDoNivelAtual = 0;

  Map<String, int> get recordesPorNivel => Map.unmodifiable(_recordesTempoPorNivel);
  Map<String, String> get datasRecordesPorNivel => Map.unmodifiable(_datasRecordesPorNivel);

  Future<void> carregarRecordesLocais() async {
    if (_recordesTempoPorNivel.isEmpty) {
      // Chaves limpas em String para evitar qualquer vazamento de objeto IconData
      _recordesTempoPorNivel['bronze'] = 450; 
      _recordesTempoPorNivel['prata'] = 520;  
      
      // Datas padrão de simulação para o painel de ranking
      _datasRecordesPorNivel['bronze'] = "21/05/2026";
      _datasRecordesPorNivel['prata'] = "21/05/2026";
      notifyListeners();
    }
  }

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

  String get nomeNivelExibicao => nivelAtual.label;
  
  Dificuldade get diculdadeTecnica {
    if (nivelAtual == Nivel.bronze) return Dificuldade.facil;
    if (nivelAtual == Nivel.prata) return Dificuldade.medio;
    return Dificuldade.dificil;
  }

  // ---------------------------------------------------
  // LÓGICA DO MODO DISPUTA (RECORDES E CRONÔMETRO)
  // ---------------------------------------------------
  int get tempoAcumuladoNivel => _tempoAcumuladoDoNivelAtual;

  void incrementarTempoGeral() {
    _tempoAcumuladoDoNivelAtual++;
    notifyListeners();
  }

  void resetTempoAcumulado() {
    _tempoAcumuladoDoNivelAtual = 0;
    notifyListeners();
  }

  String formatarMinutos(int segundosTotais) {
    if (segundosTotais <= 0) return "0m 00s";
    int minutos = segundosTotais ~/ 60;
    int segundosRestantes = segundosTotais % 60;
    return "${minutos}m ${segundosRestantes.toString().padLeft(2, '0')}s";
  }

  int? obterRecordeDesteNivel(Nivel nivel) => _recordesTempoPorNivel[nivel.name];

  int obterRecordeDoSharedPreferences(String nomeNivel) {
    return _recordesTempoPorNivel[nomeNivel.toLowerCase()] ?? 0;
  }

  String obterDataDoRecorde(String nomeNivel) {
    return _datasRecordesPorNivel[nomeNivel.toLowerCase()] ?? "--/--/----";
  }

  int get tempoTotalDisputaCombinado => _recordesTempoPorNivel.values.fold(0, (total, t) => total + t);

  void acumularTempoDaFase(int segundosDaFase) {
    _tempoAcumuladoDoNivelAtual += segundosDaFase;
    notifyListeners();
  }

  bool verificarESalvarRecordeDoNivelCompleto(String nomeNivel) {
    final String chave = nomeNivel.toLowerCase();
    final int? tempoAntigo = _recordesTempoPorNivel[chave];
    final int tempoFinalDoNivel = _tempoAcumuladoDoNivelAtual;

    if (tempoAntigo == null || tempoAntigo == 0 || tempoFinalDoNivel < tempoAntigo) {
      _recordesTempoPorNivel[chave] = tempoFinalDoNivel;
      
      // Captura e formata a data atual do recorde de forma limpa
      final DateTime agora = DateTime.now();
      _datasRecordesPorNivel[chave] = 
          "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";
          
      notifyListeners();
      return true; 
    }
    return false; 
  }

  // ---------------------------------------------------
  // CONVERSOR AUXILIAR DE TEXTO FALADO PARA NÚMERO
  // ---------------------------------------------------
  String normalizarRespostaFalada(String texto) {
    String limpo = texto.trim().toLowerCase();
    
    final dicionarioNumeros = {
      'zero': '0', 'um': '1', 'dois': '2', 'três': '3', 'tres': '3',
      'quatro': '4', 'cinco': '5', 'seis': '6', 'meia': '6', 'sete': '7',
      'oito': '8', 'nove': '9', 'dez': '10', 'onze': '11', 'doze': '12',
      'treze': '13', 'quatorze': '14', 'quinze': '15', 'dezesseis': '16',
      'dezessete': '17', 'dezoito': '18', 'dezenove': '19', 'vinte': '20',
      'trinta': '30', 'quarenta': '40', 'cinquenta': '50', 'sessenta': '60',
      'setenta': '70', 'oitenta': '80', 'noventa': '90', 'cem': '100'
    };

    if (dicionarioNumeros.containsKey(limpo)) {
      return dicionarioNumeros[limpo]!;
    }
    return limpo; 
  }

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO
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

  void recomecarNivelAtual() {
    faseAtual = 1;
    _tempoAcumuladoDoNivelAtual = 0;
    resetFase();
  }

  void concluirEAvancarFase() {
    if (faseAtual < maxFasesPorNivel) {
      faseAtual++;
    } else {
      _subirNivel();
      faseAtual = 1;
      _tempoAcumuladoDoNivelAtual = 0; 
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
    _tempoAcumuladoDoNivelAtual = 0;
    notifyListeners();
  }

  // ---------------------------------------------------
  // PERSISTÊNCIA
  // ---------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'fase_atual': faseAtual,
      'xp_total': xpTotal,
      'nivel_atual': nivelAtual.name,
      'perfil_usuario': perfil,
      'recordes_disputa': _recordesTempoPorNivel, 
      'datas_recordes': _datasRecordesPorNivel,
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

    if (map['recordes_disputa'] != null) {
      _recordesTempoPorNivel.clear();
      (map['recordes_disputa'] as Map<String, dynamic>).forEach((key, value) {
        _recordesTempoPorNivel[key] = value as int;
      });
    }

    if (map['datas_recordes'] != null) {
      _datasRecordesPorNivel.clear();
      (map['datas_recordes'] as Map<String, dynamic>).forEach((key, value) {
        _datasRecordesPorNivel[key] = value as String;
      });
    }
    
    notifyListeners();
  }
}