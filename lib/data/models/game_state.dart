import 'package:flutter/material.dart';
import 'package:matematicadivertida/core/enums/nivel_enum.dart';
import 'package:matematicadivertida/core/enums/nivel_ext.dart'; // Garante acesso a .icone, .label e .multiplicadorXP
import 'package:matematicadivertida/core/config/estrutura_pedagogica.dart';

/// [GameState] gerencia o estado reativo do jogo.
class GameState extends ChangeNotifier {
  
  // ---------------------------------------------------
  // PROPRIEDADES NATIVAS (ESTADO)
  // ---------------------------------------------------
  int faseAtual = 1;
  int perguntaAtual = 1; 
  int xpTotal = 0; 
  int acertosNaFase = 0;
  int errosNaFase = 0;
  int vidas = 3; 
  int pontosAcumuladosFase = 0;
  Nivel nivelAtual = Nivel.bronze;
  String perfil = "crianca";

  // ---------------------------------------------------
  // ALIASES PARA COMPATIBILIDADE (RESOLVE ERROS DE UI)
  // ---------------------------------------------------
  
  /// Resolve o erro: 'indicePerguntaAtual' isn't defined
  int get indicePerguntaAtual => perguntaAtual;

  /// Resolve o erro: 'nivel' isn't defined no GameHUD
  String get nivel => nivelAtual.label;

  /// Resolve o erro: 'fase' isn't defined no GameHUD
  int get fase => faseAtual;

  /// Alias para xpTotal se algum widget ainda chamar 'pontos'
  int get pontos => xpTotal;
  set pontos(int valor) {
    xpTotal = valor;
    notifyListeners();
  }

  // ---------------------------------------------------
  // GETTERS DE CONFIGURAÇÃO & UI
  // ---------------------------------------------------
  int get maxPerguntasPorFase => EstruturaProgresso.perguntasPorFase;
  int get maxFasesPorNivel => EstruturaProgresso.fasesPorNivel;
  
  String get perfilUsuario => perfil;
  int get acertos => acertosNaFase;
  int get erros => errosNaFase;

  /// Retorna string formatada: "🥉 Bronze"
  String get nomeNivelExibicao => "${nivelAtual.icone} ${nivelAtual.label}";
  
  /// Formata o nome para o banco de dados (ex: "Bronze")
  String get nivelParaService => nivelAtual.name[0].toUpperCase() + nivelAtual.name.substring(1);

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO
  // ---------------------------------------------------

  void registrarAcerto() {
    acertosNaFase++;
    
    // Cálculo baseado no multiplicador de XP definido na extensão do Enum
    int pontosGanhos = (10 * nivelAtual.multiplicadorXP).toInt();
    
    xpTotal += pontosGanhos;
    pontosAcumuladosFase += pontosGanhos;
    
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
    
    // Penalidade: perde o que ganhou apenas na fase atual
    xpTotal -= pontosAcumuladosFase;
    if (xpTotal < 0) xpTotal = 0;
    
    pontosAcumuladosFase = 0;
    notifyListeners();
  }

  void concluirEAvancarFase() {
    if (faseAtual < maxFasesPorNivel) {
      faseAtual++;
    } else {
      subirNivel();
      faseAtual = 1;
    }
    
    perguntaAtual = 1;
    acertosNaFase = 0;
    errosNaFase = 0;
    vidas = 3;
    pontosAcumuladosFase = 0;
    
    notifyListeners();
  }

  void subirNivel() {
    nivelAtual = switch (nivelAtual) {
      Nivel.bronze  => Nivel.prata,
      Nivel.prata   => Nivel.ouro,
      Nivel.ouro    => Nivel.platina,
      Nivel.platina => Nivel.mestre,
      Nivel.mestre  => Nivel.mestre,
    };
    notifyListeners();
  }

  void resetJogo() {
    faseAtual = 1;
    perguntaAtual = 1;
    xpTotal = 0;
    acertosNaFase = 0;
    errosNaFase = 0;
    vidas = 3;
    pontosAcumuladosFase = 0;
    nivelAtual = Nivel.bronze;
    notifyListeners();
  }

  // ---------------------------------------------------
  // PERSISTÊNCIA (FIREBASE)
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