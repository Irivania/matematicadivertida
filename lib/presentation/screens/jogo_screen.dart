// lib/presentation/screens/jogo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/models/game_state.dart';
import '../../../data/services/pergunta_service.dart';
import '../../../data/services/jogo_flow_service.dart';
import '../../../data/services/jogo_voice_service.dart';
import '../widgets/jogo/area_pergunta.dart';
import '../widgets/jogo/hud_widget.dart';
import '../widgets/jogo/progress_widget.dart';

class JogoScreen extends StatefulWidget {
  final String perfil;
  final bool isModoDisputa;

  const JogoScreen({super.key, required this.perfil, this.isModoDisputa = false});

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> {
  late JogoFlowService _flow;
  late JogoVoiceService _voice;
  final _respostaController = TextEditingController();
  final _respostaFocusNode = FocusNode();
  
  // CORREÇÃO: Foco específico para o botão de menu
  final _menuButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _flow = JogoFlowService(
      context: context,
      perfil: widget.perfil,
      disputaAtiva: widget.isModoDisputa,
      perguntaService: PerguntaService(),
      respostaController: _respostaController,
      atualizarTela: () => setState(() {}),
    );
    _voice = JogoVoiceService(context: context);
  }

  @override
  void dispose() {
    _flow.dispose();
    _voice.pararTudo();
    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _menuButtonFocusNode.dispose(); // CORREÇÃO
    super.dispose();
  }

  void _garantirFocoPergunta() {
    Future.microtask(() {
      if (_respostaFocusNode.canRequestFocus) _respostaFocusNode.requestFocus();
    });
  }
  
  // CORREÇÃO: Garante o foco no botão de menu ao abrir
  void _garantirFocoMenu() {
    Future.microtask(() {
      if (_menuButtonFocusNode.canRequestFocus) _menuButtonFocusNode.requestFocus();
    });
  }

  void _iniciarJogo() {
    if (_flow.jogoAtivo) return;
    context.read<GameState>().limparProgresso();
    _flow.iniciarDesafio(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    _garantirFocoPergunta();
  }

  void _continuarPartida() {
    context.read<GameState>().carregarProgresso();
    _flow.continuarPartida();
    _garantirFocoPergunta();
  }

  void _executarValidacao() {
    _flow.validarResposta(
      onAcerto: () {
        HapticFeedback.lightImpact();
        context.read<GameState>().registrarAcerto(tempoRestante: _flow.displayTempo, ehModoDisputa: widget.isModoDisputa);
        _flow.processarAcerto(onConcluirFase: () => _mostrarDialogo(true));
      },
      onErro: (correta) {
        HapticFeedback.heavyImpact();
        _flow.pausarJogo();
        _mostrarDialogo(false);
      },
    );
  }

  void _mostrarDialogo(bool isFimFase) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isFimFase ? "🎉 Fase Concluída!" : "❌ Ops!"),
        content: Text(isFimFase ? "Preparando próxima fase... 🚀" : "Tente novamente!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmarDialogo(isFimFase);
            },
            child: const Text("CONTINUAR"),
          ),
        ],
      ),
    );
  }

  void _confirmarDialogo(bool isFimFase) {
    if (isFimFase) {
      context.read<GameState>().concluirEAvancarFase();
      _flow.gerarPergunta();
    } else {
      _flow.retomarJogo();
    }
    _garantirFocoPergunta();
  }
  
  void _exibirDica() {
    if (!_flow.jogoAtivo || _flow.perguntaAtual == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dica do Cal! 💡"),
        content: Text(_flow.perguntaAtual!.dica ?? "Analise com calma!"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendi!"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    
    // CORREÇÃO: Garante o foco ao abrir a tela no menu
    if (!_flow.jogoAtivo && !_menuButtonFocusNode.hasFocus) {
       _garantirFocoMenu();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/${widget.perfil}.png', fit: BoxFit.cover)),
          
          // CONTEÚDO PRINCIPAL (SafeArea)
          SafeArea(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                  IconButton(icon: Icon(gs.acessibilidadeAtiva ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 30), onPressed: () => gs.alternarAcessibilidadeVoz()),
                ]),
                const SizedBox(height: 245),
                HUDWidget(state: gs, isDisputa: _flow.disputaAtiva, tempoRestante: _flow.displayTempo),
                ProgressWidget(perguntaAtual: gs.indicePerguntaAtual, totalPerguntas: gs.maxPerguntasPorFase, disputaAtiva: _flow.disputaAtiva),
                const Spacer(),
                if (!_flow.jogoAtivo)
                  Center(
                    child: Column(
                      children: [
                        if (gs.temPartidaSalva) _buildMenuButton("CONTINUAR", Colors.orange, _continuarPartida),
                        const SizedBox(height: 20),
                        
                        // CORREÇÃO DEFINTIVA DE FOCO NO ENTER
                        Focus(
                          focusNode: _menuButtonFocusNode, // Usa o FocusNode específico
                          onKey: (node, event) {
                            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                              _iniciarJogo();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: _buildMenuButton(gs.temPartidaSalva ? "NOVO JOGO" : "COMEÇAR", Colors.green, _iniciarJogo),
                        ),
                      ],
                    ),
                  )
                else
                  AreaPerguntaWidget(
                    key: ValueKey(_flow.perguntaAtual?.pergunta),
                    perguntaAtual: _flow.perguntaAtual,
                    jogoAtivo: _flow.jogoAtivo,
                    disputaAtiva: _flow.disputaAtiva,
                    controller: _respostaController,
                    focusNode: _respostaFocusNode,
                    onValidar: _executarValidacao,
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
          
          // MASCOTE CAL: Fixado no Stack, fora do SafeArea, com GestureDetector Translucid
          Positioned(
            bottom: 20, 
            right: 20, 
            child: GestureDetector(
              onTap: _exibirDica,
              behavior: HitTestBehavior.translucent, // CORREÇÃO DE TOQUE
              child: Image.asset('assets/images/mascote_cal.png', width: 100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: Text(text, style: const TextStyle(fontSize: 28, color: Colors.white)),
    );
  }
}