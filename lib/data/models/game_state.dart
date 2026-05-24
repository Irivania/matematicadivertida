import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/calcular_pontuacao_usecase.dart';
import '../../core/enums/nivel_enum.dart';
import '../../core/config/estrutura_pedagogica.dart';

class CustosJogo {
  static const int custoVidaExtra = 500;
  static const int custoPuloPergunta = 1000;
}

class GameState extends ChangeNotifier {
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  // Estados de Jogo
  int faseAtual = 1;
  int perguntaAtual = 1; 
  int acertosNaFase = 0;
  int errosNaFase = 0;
  int vidas = 3; 
  Nivel nivelAtual = Nivel.bronze;
  String perfil = "crianca"; 
  int _tempoAcumuladoDoNivelAtual = 0;

  Map<String, int> _xpPorPerfil = {'crianca': 0, 'adulto': 0, 'professor': 0};
  
  int progressoMissaoDiaria = 0;
  final int metaMissaoDiaria = 10;
  bool acessibilidadeVoz = false;

  final Map<String, int> _recordesTempoPorNivel = {};
  final Map<String, String> _nomesRecordesPorNivel = {};

  GameState() { _carregarProgressoMissao(); }

  // --- COMPATIBILIDADE PARA NÃO QUEBRAR OUTRAS TELAS ---
  int get pontos => _xpPorPerfil[perfil.toLowerCase()] ?? 0;
  int get xpTotal => pontos; 
  Map<String, int> get recordesPorNivel => _recordesTempoPorNivel;
  Map<String, String> get nomesRecordesPorNivel => _nomesRecordesPorNivel;

  // --- MÉTODOS DE PERFIL ---
  void definirPerfil(String novoPerfil) {
    perfil = novoPerfil.toLowerCase();
    notifyListeners();
  }

  // --- ECONOMIA ---
  bool comprarVidaExtra() {
    int saldo = pontos;
    if (saldo >= CustosJogo.custoVidaExtra) {
      _xpPorPerfil[perfil.toLowerCase()] = saldo - CustosJogo.custoVidaExtra;
      vidas++; 
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- LÓGICA DE JOGO ---
  void registrarAcerto({int tempoRestante = 0, bool ehModoDisputa = false}) {
    acertosNaFase++;
    int mult = ehModoDisputa ? 2 : 1;
    int pontosGanhos = _calcularPontuacao.executar(acertos: 1, dificuldade: diculdadeTecnica, tempoRestante: tempoRestante) * mult;
    
    String p = perfil.toLowerCase();
    _xpPorPerfil[p] = (_xpPorPerfil[p] ?? 0) + pontosGanhos;
    
    registrarProgressoMissao();
    notifyListeners();
  }

  // --- GETTERS E FORMATADORES ---
  int get fase => faseAtual;
  int get indicePerguntaAtual => perguntaAtual;
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get tempoAcumuladoNivel => _tempoAcumuladoDoNivelAtual;
  String get nomeNivelExibicao => nivelAtual.name.toUpperCase();
  String get nivelParaService => nivelAtual.name;

  String formatarMinutos(int segundos) {
    int min = segundos ~/ 60;
    int sec = segundos % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  // --- MISSÕES E RESET ---
  Future<void> _carregarProgressoMissao() async {
    final prefs = await SharedPreferences.getInstance();
    progressoMissaoDiaria = prefs.getInt('progresso_missao') ?? 0;
    notifyListeners();
  }

  Future<void> registrarProgressoMissao() async {
    if (progressoMissaoDiaria < metaMissaoDiaria) {
      progressoMissaoDiaria++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('progresso_missao', progressoMissaoDiaria);
      if (progressoMissaoDiaria == metaMissaoDiaria) {
        String p = perfil.toLowerCase();
        _xpPorPerfil[p] = (_xpPorPerfil[p] ?? 0) + 200;
      }
      notifyListeners();
    }
  }

  void registrarErro() { errosNaFase++; if (vidas > 0) vidas--; notifyListeners(); }
  void avancarPergunta() { if (perguntaAtual < maxPerguntasPorFase) { perguntaAtual++; notifyListeners(); } }
  void incrementarTempoGeral() { _tempoAcumuladoDoNivelAtual++; notifyListeners(); }
  void resetTempoAcumulado() { _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void alternarAcessibilidadeVoz() { acessibilidadeVoz = !acessibilidadeVoz; notifyListeners(); }

  void resetarNivelParaInicio() {
    faseAtual = 1; perguntaAtual = 1; acertosNaFase = 0; errosNaFase = 0; vidas = 3; _tempoAcumuladoDoNivelAtual = 0;
    notifyListeners();
  }

  void resetFase() { perguntaAtual = 1; acertosNaFase = 0; errosNaFase = 0; vidas = 3; notifyListeners(); }

  void concluirEAvancarFase() {
    if (faseAtual < EstruturaProgresso.fasesPorNivel) {
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
      Nivel.bronze => Nivel.prata, Nivel.prata => Nivel.ouro,
      Nivel.ouro => Nivel.platina, Nivel.platina => Nivel.mestre,
      _ => Nivel.mestre,
    };
  }

  Dificuldade get diculdadeTecnica => switch(nivelAtual) {
    Nivel.bronze => Dificuldade.facil,
    Nivel.prata => Dificuldade.medio,
    _ => Dificuldade.dificil,
  };

  String normalizarRespostaFalada(String texto) => texto.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  
  Future<void> carregarRecordesLocais() async { notifyListeners(); }
  String obterDataDoRecorde(String nivel) => "--/--/----";
  String obterTipoMedalha(int tempo) => "🥉 Bronze";
}