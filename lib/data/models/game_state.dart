// lib/data/models/game_state.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/ranking_service.dart';
import '../../domain/usecases/calcular_pontuacao_usecase.dart';
import '../../core/enums/nivel_enum.dart';
import '../../core/config/estrutura_pedagogica.dart';

class GameState extends ChangeNotifier {
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  // Estados do Jogo
  int faseAtual = 1;
  int perguntaAtual = 1; 
  int vidas = 3; 
  Nivel nivelAtual = Nivel.bronze;
  String perfil = "crianca"; 
  int _tempoAcumuladoDoNivelAtual = 0;
  bool _temPartidaSalva = false;
  
  // Armazena os recordes mapeados por perfil e nível
  Map<String, int> _melhoresTemposPorPerfil = {};
  Map<String, int> _xpPorPerfil = {'crianca': 0, 'adulto': 0, 'professor': 0};
  
  // Armazena o tempo gasto em cada fase (1 a 10) para alimentar o gráfico de desempenho
  final Map<int, int> _temposPorFase = {};

  int progressoMissaoDiaria = 0;
  final int metaMissaoDiaria = 10;
  bool acessibilidadeVoz = false;

  GameState() { _carregarEstadoInicial(); }

  Future<void> _carregarEstadoInicial() async {
    final prefs = await SharedPreferences.getInstance();
    progressoMissaoDiaria = prefs.getInt('progresso_missao') ?? 0;
    _temPartidaSalva = prefs.getBool('tem_partida_salva') ?? false;
    
    for (var p in ['crianca', 'adulto', 'professor']) {
      for (var nivel in Nivel.values) {
        String chave = '${p}_${nivel.name}';
        _melhoresTemposPorPerfil[chave] = prefs.getInt('recorde_$chave') ?? 0;
      }
    }
    notifyListeners();
  }

  // --- GETTERS COMPATÍVEIS COM AS TELAS ---
  bool get temPartidaSalva => _temPartidaSalva;
  int get pontos => _xpPorPerfil[perfil.toLowerCase()] ?? 0;
  int get xpTotal => pontos;
  int get fase => faseAtual;
  int get indicePerguntaAtual => perguntaAtual;
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get tempoAcumuladoNivel => _tempoAcumuladoDoNivelAtual;
  String get nivelParaService => nivelAtual.name;
  String get nomeNivelExibicao => nivelAtual.name.toUpperCase();
  bool get acessibilidadeAtiva => acessibilidadeVoz;

  Map<String, int> get recordesPorNivel {
    Map<String, int> mapPerfil = {};
    for (var nivel in Nivel.values) {
      mapPerfil[nivel.name] = _melhoresTemposPorPerfil['${perfil.toLowerCase()}_${nivel.name}'] ?? 0;
    }
    return mapPerfil;
  }

  Map<String, String> get nomesRecordesPorNivel => {};

  // --- MÉTODOS AUXILIARES E FORMATAÇÕES ---
  String formatarMinutos(int s) => "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
  String normalizarRespostaFalada(String texto) => texto.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  String obterDataDoRecorde(String nivel) => "--/--/----";

  void definirPerfil(String novoPerfil) { 
    perfil = novoPerfil.toLowerCase(); 
    notifyListeners(); 
  }
  
  void carregarRecordesLocais() => notifyListeners();
  void resetFase() { perguntaAtual = 1; notifyListeners(); }
  void resetarPerguntaParaPrimeira() { perguntaAtual = 1; notifyListeners(); }
  void resetarNivelParaInicioDoNivel() { faseAtual = 1; perguntaAtual = 1; _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void resetTempoAcumulado() { _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void zerarTempoAoPassarDeNivel() { _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void alternarAcessibilidadeVoz() { acessibilidadeVoz = !acessibilidadeVoz; notifyListeners(); }
  
  bool comprarVidaExtra() {
    if (pontos >= 500) {
      _xpPorPerfil[perfil.toLowerCase()] = pontos - 500;
      vidas++; 
      notifyListeners(); 
      return true;
    }
    return false;
  }

  // --- GERENCIAMENTO DE TEMPOS POR FASE (PARA O GRÁFICO) ---
  void registrarTempoFase(int fase, int segundos) {
    _temposPorFase[fase] = segundos;
    notifyListeners();
  }

  int obterTempoDaFase(int fase) => _temposPorFase[fase] ?? 0;

  // --- NOVO: MÉTODO PARA RETORNAR O TEMPO TOTAL DO NÍVEL ---
  int obterTempoTotalNivel(String nivelNome) {
    String chave = '${perfil.toLowerCase()}_$nivelNome';
    return _melhoresTemposPorPerfil[chave] ?? 0;
  }

  // --- LÓGICA DE MEDALHAS E TEMPO SEPARADA POR PERFIL ---
  Future<void> salvarRecorde(String nivelNome, int tempo) async {
    final prefs = await SharedPreferences.getInstance();
    String chave = '${perfil.toLowerCase()}_$nivelNome';
    int recordeAtual = _melhoresTemposPorPerfil[chave] ?? 0;
    
    if (recordeAtual == 0 || tempo < recordeAtual) {
      _melhoresTemposPorPerfil[chave] = tempo;
      await prefs.setInt('recorde_$chave', tempo);
      notifyListeners();

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String nomeUsuario = "${user.displayName ?? user.email?.split('@').first ?? 'Estudante'} (${perfil.toUpperCase()})";
          
          await RankingService().salvarPontuacaoGlobal(
            uid: '${user.uid}_${perfil.toLowerCase()}',
            nome: nomeUsuario,
            nivel: '$nivelNome (${perfil.toUpperCase()})',
            tempo: tempo,
          );
        }
      } catch (e) {
        debugPrint("Erro ao sincronizar ranking global: $e");
      }
    }
  }

  String obterTipoMedalha(String nivelNome) {
    String chave = '${perfil.toLowerCase()}_$nivelNome';
    int tempo = _melhoresTemposPorPerfil[chave] ?? 0;
    if (tempo == 0) return "";
    if (tempo < 60) return "🥇 Ouro";
    if (tempo < 120) return "🥈 Prata";
    return "🥉 Bronze";
  }

  void concluirEAvancarFase() {
    registrarTempoFase(faseAtual, _tempoAcumuladoDoNivelAtual);

    if (faseAtual < EstruturaProgresso.fasesPorNivel) {
      faseAtual++;
    } else { 
      salvarRecorde(nivelAtual.name, _tempoAcumuladoDoNivelAtual);
      _subirNivel(); 
      faseAtual = 1; 
      zerarTempoAoPassarDeNivel(); 
    }
    perguntaAtual = 1;
    limparProgresso();
    notifyListeners();
  }

  void _subirNivel() {
    nivelAtual = switch (nivelAtual) {
      Nivel.bronze => Nivel.prata, 
      Nivel.prata => Nivel.ouro,
      Nivel.ouro => Nivel.platina, 
      Nivel.platina => Nivel.mestre,
      _ => Nivel.mestre,
    };
  }

  // --- PERSISTÊNCIA GERAL ---
  Future<void> salvarProgressoCompleto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tem_partida_salva', true);
    await prefs.setInt('fase_salva', faseAtual);
    await prefs.setInt('pergunta_salva', perguntaAtual);
    await prefs.setInt('xp_salvo', pontos);
    await prefs.setInt('tempo_salvo', _tempoAcumuladoDoNivelAtual);
    _temPartidaSalva = true;
    notifyListeners();
  }

  Future<void> carregarProgresso() async {
    final prefs = await SharedPreferences.getInstance();
    faseAtual = prefs.getInt('fase_salva') ?? 1;
    perguntaAtual = prefs.getInt('pergunta_salva') ?? 1;
    _tempoAcumuladoDoNivelAtual = prefs.getInt('tempo_salvo') ?? 0;
    _temPartidaSalva = true;
    notifyListeners();
  }

  void limparProgresso() async {
    _temPartidaSalva = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tem_partida_salva');
    await prefs.remove('fase_salva');
    await prefs.remove('pergunta_salva');
    await prefs.remove('tempo_salvo');
    notifyListeners();
  }

  void registrarAcerto({int tempoRestante = 0, bool ehModoDisputa = false}) {
    int mult = ehModoDisputa ? 2 : 1;
    int pontosGanhos = _calcularPontuacao.executar(acertos: 1, dificuldade: dificuldadeTecnica, tempoRestante: tempoRestante) * mult;
    _xpPorPerfil[perfil.toLowerCase()] = (_xpPorPerfil[perfil.toLowerCase()] ?? 0) + pontosGanhos;
    registrarProgressoMissao();
    salvarProgressoCompleto();
    notifyListeners();
  }

  Future<void> registrarProgressoMissao() async {
    progressoMissaoDiaria++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progresso_missao', progressoMissaoDiaria);
    notifyListeners();
  }

  void avancarPergunta() { 
    if (perguntaAtual < maxPerguntasPorFase) { 
      perguntaAtual++; 
      salvarProgressoCompleto();
      notifyListeners(); 
    } 
  }

  Dificuldade get dificuldadeTecnica => switch(nivelAtual) {
    Nivel.bronze => Dificuldade.facil,
    Nivel.prata => Dificuldade.medio,
    _ => Dificuldade.dificil,
  };

  void incrementarTempoGeral() { _tempoAcumuladoDoNivelAtual++; notifyListeners(); }
}