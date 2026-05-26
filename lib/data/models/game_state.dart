import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  Map<String, int> _xpPorPerfil = {'crianca': 0, 'adulto': 0, 'professor': 0};
  int progressoMissaoDiaria = 0;
  final int metaMissaoDiaria = 10;
  bool acessibilidadeVoz = false;

  GameState() { _carregarEstadoInicial(); }

  Future<void> _carregarEstadoInicial() async {
    final prefs = await SharedPreferences.getInstance();
    progressoMissaoDiaria = prefs.getInt('progresso_missao') ?? 0;
    _temPartidaSalva = prefs.getBool('tem_partida_salva') ?? false;
    notifyListeners();
  }

  // --- PERSISTÊNCIA ---
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

  // --- GETTERS ---
  bool get temPartidaSalva => _temPartidaSalva;
  int get pontos => _xpPorPerfil[perfil.toLowerCase()] ?? 0;
  int get xpTotal => pontos;
  int get fase => faseAtual;
  int get indicePerguntaAtual => perguntaAtual;
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get tempoAcumuladoNivel => _tempoAcumuladoDoNivelAtual;
  String get nivelParaService => nivelAtual.name;
  String get nomeNivelExibicao => nivelAtual.name.toUpperCase();
  String get nomePerfil => perfil;
  int get vidasRestantes => vidas;
  bool get acessibilidadeAtiva => acessibilidadeVoz;

  // --- MÉTODOS SOLICITADOS PELO COMPILADOR ---
  String formatarMinutos(int s) => "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
  
  String normalizarRespostaFalada(String texto) => texto.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  
  void definirPerfil(String novoPerfil) { 
    perfil = novoPerfil.toLowerCase(); 
    notifyListeners(); 
  }

  bool comprarVidaExtra() {
    if (pontos >= 500) {
      _xpPorPerfil[perfil.toLowerCase()] = pontos - 500;
      vidas++; 
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- MOCKS PARA COMPATIBILIDADE ---
  void carregarRecordesLocais() => notifyListeners();
  Map<String, int> get recordesPorNivel => {};
  Map<String, String> get nomesRecordesPorNivel => {};
  String obterDataDoRecorde(String nivel) => "--/--/----";
  String obterTipoMedalha(int tempo) => "🥉 Bronze";

  // --- AÇÕES DO JOGO ---
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

  void concluirEAvancarFase() {
    if (faseAtual < EstruturaProgresso.fasesPorNivel) faseAtual++;
    else { _subirNivel(); faseAtual = 1; _tempoAcumuladoDoNivelAtual = 0; }
    perguntaAtual = 1;
    limparProgresso();
    notifyListeners();
  }

  void _subirNivel() {
    nivelAtual = switch (nivelAtual) {
      Nivel.bronze => Nivel.prata, Nivel.prata => Nivel.ouro,
      Nivel.ouro => Nivel.platina, Nivel.platina => Nivel.mestre,
      _ => Nivel.mestre,
    };
  }

  Dificuldade get dificuldadeTecnica => switch(nivelAtual) {
    Nivel.bronze => Dificuldade.facil,
    Nivel.prata => Dificuldade.medio,
    _ => Dificuldade.dificil,
  };

  void incrementarTempoGeral() { _tempoAcumuladoDoNivelAtual++; salvarProgressoCompleto(); notifyListeners(); }
  void resetFase() { perguntaAtual = 1; notifyListeners(); }
  void resetTempoAcumulado() { _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void resetarNivelParaInicio() { faseAtual = 1; perguntaAtual = 1; vidas = 3; _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }
  void alternarAcessibilidadeVoz() { acessibilidadeVoz = !acessibilidadeVoz; notifyListeners(); }
}