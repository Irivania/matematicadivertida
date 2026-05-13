import 'package:flutter/material.dart';
import 'package:matematicadivertida/data/models/game_state.dart';
import 'package:matematicadivertida/core/enums/nivel_enum.dart';
import 'package:matematicadivertida/core/config/game_config.dart';

class GameController extends ChangeNotifier {
  // O contexto pode ser útil para navegar ou mostrar Dialogs futuramente
  final BuildContext context;

  // PROPRIEDADES
  // Mudança: Inicializamos o GameState e garantimos que ele seja reativo
  final GameState _state; 
  GameState get state => _state;

  // CONSTRUTOR
  // CORREÇÃO: Agora aceita o parâmetro nomeado 'context' exigido pela JogoScreen
  GameController({required this.context}) : _state = GameState();

  // ---------------------------------------------------
  // MÉTODOS DE LÓGICA DE JOGO
  // ---------------------------------------------------

  /// Método para iniciar as configurações da partida
  void iniciarJogo() {
    debugPrint("Iniciando partida...");
    // Aqui você pode carregar perguntas do Firebase ou localmente
  }

  /// Método chamado quando o usuário termina uma fase.
  /// Resolve o erro: "The method 'faseCompleta' isn't defined"
  void faseCompleta({required int acertos, required int totalPerguntas}) {
    // Cálculo de XP baseado na lógica do seu GameState
    int xpGanhado = acertos * 10;
    
    // Atualiza o estado
    _state.xpTotal += xpGanhado;
    
    // Lógica de progressão: Passa se acertou 60%
    if (acertos >= (totalPerguntas * 0.6)) {
      _state.faseAtual++;
      _verificarSubidaDeNivel();
    }

    notifyListeners();
  }

  /// Verifica se o XP atual é suficiente para mudar o Nivel (Bronze -> Prata, etc)
  void _verificarSubidaDeNivel() {
    // Exemplo: lógica baseada nas configurações do GameConfig
    int nivelAlvo = (_state.xpTotal ~/ (GameConfig.perguntasPorNivel * 10));
    
    if (nivelAlvo < Nivel.values.length) {
      _state.nivelAtual = Nivel.values[nivelAlvo];
    }
  }

  // ---------------------------------------------------
  // GETTERS DE COMPATIBILIDADE
  // ---------------------------------------------------

  /// Getter para UI saber quantas fases existem no nível atual
  /// Resolve o erro: "The getter 'fasesPorNivel' isn't defined"
  int get fasesPorNivel => GameConfig.fasesPorNivel;

  /// Alias para facilitar o acesso à pontuação
  int get pontuacaoAtual => _state.xpTotal;
}