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
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  void _garantirFocoPergunta() => Future.microtask(() => _respostaFocusNode.requestFocus());
  void _garantirFocoMenu() => Future.microtask(() => _menuButtonFocusNode.requestFocus());

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
      builder: (BuildContext dialogContext) {
        return Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  Navigator.of(dialogContext).pop();
                  _confirmarDialogo(isFimFase);
                  return null;
                },
              ),
            },
            child: AlertDialog(
              title: Text(isFimFase ? "🎉 Fase Concluída!" : "❌ Ops!"),
              content: Text(isFimFase ? "Preparando próxima fase... 🚀" : "Tente novamente!"),
              actions: [
                TextButton(
                  autofocus: true,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _confirmarDialogo(isFimFase);
                  },
                  child: const Text("CONTINUAR"),
                ),
              ],
            ),
          ),
        );
      },
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
    if (!_flow.jogoAtivo && !_menuButtonFocusNode.hasFocus) _garantirFocoMenu();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/${widget.perfil}.png', 
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                  IconButton(icon: Icon(gs.acessibilidadeAtiva ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 30), onPressed: () => gs.alternarAcessibilidadeVoz()),
                ]),
                
                const SizedBox(height: 282),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      HUDWidget(state: gs, isDisputa: _flow.disputaAtiva, tempoRestante: _flow.displayTempo),
                      const Divider(color: Colors.white24, height: 20),
                      Text("Pergunta ${gs.indicePerguntaAtual} de ${gs.maxPerguntasPorFase}", 
                           style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const Spacer(),
                if (!_flow.jogoAtivo)
                  Center(child: Column(children: [
                    if (gs.temPartidaSalva) _buildMenuButton("CONTINUAR", Colors.orange, _continuarPartida),
                    const SizedBox(height: 20),
                    Focus(
                      focusNode: _menuButtonFocusNode,
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                          _iniciarJogo();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: _buildMenuButton(gs.temPartidaSalva ? "NOVO JOGO" : "COMEÇAR", Colors.green, _iniciarJogo),
                    ),
                  ]))
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
          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            bottom: !widget.isModoDisputa ? MediaQuery.of(context).size.height * 0.20 : 20.0,
            right: 20,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              scale: !widget.isModoDisputa ? 1.5 : 1.0,
              child: GestureDetector(
                onTap: _exibirDica,
                behavior: HitTestBehavior.translucent,
                child: Container(
                  decoration: !widget.isModoDisputa ? BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                  ) : null,
                  child: Image.asset('assets/images/mascote_cal.png', width: 100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    child: Text(text, style: const TextStyle(fontSize: 28, color: Colors.white)),
  );
}