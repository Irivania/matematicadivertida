import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/calcular_pontuacao_usecase.dart';
import '../../core/enums/nivel_enum.dart';
import '../../core/config/estrutura_pedagogica.dart';

class GameState extends ChangeNotifier {
  final _calcularPontuacao = CalcularPontuacaoUseCase();

  int faseAtual = 1;
  int perguntaAtual = 1; 
  int xpTotal = 0; 
  int acertosNaFase = 0;
  int errosNaFase = 0;
  int vidas = 3; 
  Nivel nivelAtual = Nivel.bronze;
  String perfil = "crianca"; 

  bool acessibilidadeVoz = false;

  void alternarAcessibilidadeVoz() {
    acessibilidadeVoz = !acessibilidadeVoz;
    notifyListeners();
  }

  // --- MÉTODOS DE RESET E AVANÇO ---
  
  // MÉTODO ADICIONADO PARA CORREÇÃO DO FLUXO DE ERRO
  void resetarFaseAtual() {
    perguntaAtual = 1; 
    acertosNaFase = 0;
    errosNaFase = 0;
    vidas = 3;
    notifyListeners(); 
  }

  // Mapas para armazenar o estado atual da sessão
  final Map<String, int> _recordesTempoPorNivel = {};
  final Map<String, String> _datasRecordesPorNivel = {};
  final Map<String, String> _nomesRecordesPorNivel = {}; 
  int _tempoAcumuladoDoNivelAtual = 0;

  Map<String, int> get recordesPorNivel => Map.unmodifiable(_recordesTempoPorNivel);
  Map<String, String> get datasRecordesPorNivel => Map.unmodifiable(_datasRecordesPorNivel);
  Map<String, String> get nomesRecordesPorNivel => Map.unmodifiable(_nomesRecordesPorNivel);

  Future<void> carregarRecordesLocais() async {
    final prefs = await SharedPreferences.getInstance();
    final niveis = ['bronze', 'prata', 'ouro', 'platina', 'mestre'];
    
    _recordesTempoPorNivel.clear();
    _datasRecordesPorNivel.clear();
    _nomesRecordesPorNivel.clear();
    
    bool houveMudanca = false;
    for (var nivel in niveis) {
      String chaveNivelPerfil = "${nivel}_${perfil.toLowerCase()}";
      
      int? tempoSalvo = prefs.getInt("recorde_tempo_$chaveNivelPerfil");
      String? dataSalva = prefs.getString("recorde_data_$chaveNivelPerfil");
      String? nomeSalvo = prefs.getString("recorde_nome_$chaveNivelPerfil");
      
      if (tempoSalvo != null && tempoSalvo > 0) {
        _recordesTempoPorNivel[nivel] = tempoSalvo;
        _datasRecordesPorNivel[nivel] = dataSalva ?? "--/--/----";
        _nomesRecordesPorNivel[nivel] = nomeSalvo ?? "JOGADOR";
        houveMudanca = true;
      }
    }
    if (houveMudanca) notifyListeners();
  }

  Future<bool> verificarESalvarRecordeDoNivelCompleto(String nomeNivel) async {
    final prefs = await SharedPreferences.getInstance();
    final String chaveNivel = nomeNivel.toLowerCase();
    final String chaveArmazenamento = "${chaveNivel}_${perfil.toLowerCase()}";
    
    final int? tempoAntigo = _recordesTempoPorNivel[chaveNivel];
    final int tempoFinalDoNivel = _tempoAcumuladoDoNivelAtual;

    if (tempoAntigo == null || tempoAntigo == 0 || tempoFinalDoNivel < tempoAntigo) {
      _recordesTempoPorNivel[chaveNivel] = tempoFinalDoNivel;
      _nomesRecordesPorNivel[chaveNivel] = perfil;
      
      final DateTime agora = DateTime.now();
      String dataFormatada = "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}";
      _datasRecordesPorNivel[chaveNivel] = dataFormatada;

      await prefs.setInt("recorde_tempo_$chaveArmazenamento", tempoFinalDoNivel);
      await prefs.setString("recorde_data_$chaveArmazenamento", dataFormatada);
      await prefs.setString("recorde_nome_$chaveArmazenamento", perfil);
      
      notifyListeners();
      return true; 
    }
    return false; 
  }

  // --- LÓGICA DE JOGO E GETTERS ---
  String obterTipoMedalha(int segundos) {
    if (segundos <= 300) return "ouro";
    if (segundos <= 600) return "prata";
    return "bronze";
  }

  int get acertos => acertosNaFase;
  String get nivelParaService => nivelAtual.name;
  int get indicePerguntaAtual => perguntaAtual;
  String get nivel => nivelAtual.label;
  int get fase => faseAtual;
  int get pontos => xpTotal;
  
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get maxFasesPorNivel => EstruturaProgresso.fasesPorNivel;
  String get nomeNivelExibicao => nivelAtual.label;
  int get tempoAcumuladoNivel => _tempoAcumuladoDoNivelAtual;
  
  Dificuldade get diculdadeTecnica {
    if (nivelAtual == Nivel.bronze) return Dificuldade.facil;
    if (nivelAtual == Nivel.prata) return Dificuldade.medio;
    return Dificuldade.dificil;
  }

  void incrementarTempoGeral() { _tempoAcumuladoDoNivelAtual++; notifyListeners(); }
  void resetTempoAcumulado() { _tempoAcumuladoDoNivelAtual = 0; notifyListeners(); }

  String formatarMinutos(int segundosTotais) {
    if (segundosTotais <= 0) return "0m 00s";
    int minutos = segundosTotais ~/ 60;
    int segundosRestantes = segundosTotais % 60;
    return "${minutos}m ${segundosRestantes.toString().padLeft(2, '0')}s";
  }

  String obterDataDoRecorde(String nomeNivel) => _datasRecordesPorNivel[nomeNivel.toLowerCase()] ?? "--/--/----";

  void acumularTempoDaFase(int segundosDaFase) {
    _tempoAcumuladoDoNivelAtual += segundosDaFase;
    notifyListeners();
  }

  String normalizarRespostaFalada(String texto) {
    String limpo = texto.trim().toLowerCase();
    final dicionarioNumeros = {
      'zero': '0', 'um': '1', 'dois': '2', 'três': '3', 'tres': '3', 'quatro': '4',
      'cinco': '5', 'seis': '6', 'meia': '6', 'sete': '7', 'oito': '8', 'nove': '9',
      'dez': '10', 'onze': '11', 'doze': '12', 'treze': '13', 'quatorze': '14',
      'quinze': '15', 'dezesseis': '16', 'dezessete': '17', 'dezoito': '18',
      'dezenove': '19', 'vinte': '20', 'trinta': '30', 'quarenta': '40', 'cinquenta': '50',
      'sessenta': '60', 'setenta': '70', 'oitenta': '80', 'noventa': '90', 'cem': '100'
    };
    return dicionarioNumeros.containsKey(limpo) ? dicionarioNumeros[limpo]! : limpo;
  }

  void registrarAcerto({int tempoRestante = 0}) {
    acertosNaFase++;
    xpTotal += _calcularPontuacao.executar(acertos: 1, dificuldade: diculdadeTecnica, tempoRestante: tempoRestante);
    notifyListeners(); 
  }

  void registrarErro() { errosNaFase++; if (vidas > 0) vidas--; notifyListeners(); }
  void avancarPergunta() { if (perguntaAtual < maxPerguntasPorFase) { perguntaAtual++; notifyListeners(); } }
  void resetFase() { perguntaAtual = 1; acertosNaFase = 0; errosNaFase = 0; vidas = 3; notifyListeners(); }
  void recomecarNivelAtual() { faseAtual = 1; _tempoAcumuladoDoNivelAtual = 0; resetFase(); }

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
      Nivel.bronze => Nivel.prata, Nivel.prata => Nivel.ouro,
      Nivel.ouro => Nivel.platina, Nivel.platina => Nivel.mestre,
      _ => Nivel.mestre,
    };
  }

  void resetJogo() {
    faseAtual = 1; perguntaAtual = 1; xpTotal = 0; acertosNaFase = 0;
    errosNaFase = 0; vidas = 3; nivelAtual = Nivel.bronze; _tempoAcumuladoDoNivelAtual = 0;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'fase_atual': faseAtual, 'xp_total': xpTotal, 'nivel_atual': nivelAtual.name,
      'perfil_usuario': perfil, 'recordes_disputa': _recordesTempoPorNivel, 
      'datas_recordes': _datasRecordesPorNivel, 'nomes_recordes': _nomesRecordesPorNivel,
      'ultima_atualizacao': DateTime.now().toIso8601String(),
    };
  }

  void fromMap(Map<String, dynamic> map) {
    faseAtual = map['fase_atual'] ?? 1;
    xpTotal = map['xp_total'] ?? 0;
    perfil = map['perfil_usuario'] ?? "JOGADOR";
    nivelAtual = Nivel.values.firstWhere((e) => e.name == map['nivel_atual'], orElse: () => Nivel.bronze);
    
    if (map['recordes_disputa'] != null) {
      _recordesTempoPorNivel.clear();
      (map['recordes_disputa'] as Map<String, dynamic>).forEach((key, value) => _recordesTempoPorNivel[key] = value as int);
    }
    if (map['nomes_recordes'] != null) {
      _nomesRecordesPorNivel.clear();
      (map['nomes_recordes'] as Map<String, dynamic>).forEach((key, value) => _nomesRecordesPorNivel[key] = value as String);
    }
    notifyListeners();
  }
}