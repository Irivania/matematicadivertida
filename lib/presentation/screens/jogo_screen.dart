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
import '../widgets/jogo/jogo_action_button.dart';
import '../widgets/jogo/mascote_dica_widget.dart';

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
  final FocusNode _keyboardFocusNode = FocusNode();

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _keyboardFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _flow.dispose();
    _voice.pararTudo();
    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _garantirFoco() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_respostaFocusNode.canRequestFocus) _respostaFocusNode.requestFocus();
  });

  void _iniciarJogo() {
    if (_flow.jogoAtivo) return;
    _flow.iniciarDesafio(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    if (_flow.perguntaAtual != null) {
      _voice.iniciarLeituraPergunta(pergunta: _flow.perguntaAtual!.pergunta, jogoAtivo: true, onAcionarMicrofone: _toggleMicrofone);
      _garantirFoco();
    }
  }

  void _executarValidacao() {
    _flow.validarResposta(
      onAcerto: () {
        _flow.processarAcerto(
          onConcluirFase: () {
            _mostrarDialogo(true);
          },
        );
        _garantirFoco();
      },
      onErro: (correta) {
        _flow.pausarJogo();
        _mostrarDialogo(false, correta: correta);
      },
    );
  }

  void _mostrarDialogo(bool isFimFase, {String correta = ""}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            _confirmarDialogo(isFimFase);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: AlertDialog(
          title: Text(isFimFase ? "Muito Bem! 🌟" : "Ops! ❌"),
          content: Text(isFimFase ? "Você completou a fase com sucesso!" : "A resposta correta era: $correta"),
          actions: [
            TextButton(onPressed: () => _confirmarDialogo(isFimFase), child: const Text("CONTINUAR"))
          ],
        ),
      ),
    );
  }

  void _confirmarDialogo(bool isFimFase) {
    Navigator.pop(context);
    
    if (isFimFase) {
      // Avança para a próxima fase
      context.read<GameState>().concluirEAvancarFase();
    } else {
      // ERRO: Reseta o índice da pergunta para o início da fase atual
      context.read<GameState>().resetarFaseAtual(); 
    }
    
    // Reinicia o desafio (seja a nova fase ou o recomeço da atual)
    _flow.iniciarDesafio(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    _garantirFoco();
  }

  void _exibirDica() {
    if (_flow.perguntaAtual == null) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Dica do Cal 🤖"), content: Text(_flow.perguntaAtual!.dica), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  void _toggleMicrofone() {
    _voice.acionarMicrofone(jogoAtivo: _flow.jogoAtivo, onTextoCapturado: (t) { setState(() => _respostaController.text = t); _executarValidacao(); }, onFinalizado: () {});
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          !_flow.jogoAtivo ? _iniciarJogo() : _executarValidacao();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => _keyboardFocusNode.requestFocus(),
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: Image.asset('assets/images/crianca.png', fit: BoxFit.cover)),
              SafeArea(
                child: Column(
                  children: [
                    Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                      child: Text(_flow.disputaAtiva ? "🏁 MODO DISPUTA ATIVO" : "🧠 MODO TREINO ATIVO", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 50),
                    HUDWidget(state: gs, isDisputa: _flow.disputaAtiva, tempoRestante: _flow.tempoRestante),
                    const SizedBox(height: 12),
                    ProgressWidget(perguntaAtual: gs.indicePerguntaAtual, totalPerguntas: gs.maxPerguntasPorFase, disputaAtiva: _flow.disputaAtiva),
                    const Spacer(),
                    AreaPerguntaWidget(perguntaAtual: _flow.perguntaAtual, jogoAtivo: _flow.jogoAtivo, disputaAtiva: _flow.disputaAtiva, controller: _respostaController, focusNode: _respostaFocusNode, onValidar: _executarValidacao),
                    const Spacer(flex: 2),
                    JogoActionButton(jogoAtivo: _flow.jogoAtivo, disputaAtiva: _flow.disputaAtiva, estaOuvindo: _voice.estaOuvindo, onIniciar: _iniciarJogo, onValidar: _executarValidacao, onMicrofone: _toggleMicrofone),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              if (_flow.jogoAtivo && !_flow.disputaAtiva) Positioned(bottom: 150, right: 20, child: MascoteDicaWidget(onExibirDica: _exibirDica)),
            ],
          ),
        ),
      ),
    );
  }
}