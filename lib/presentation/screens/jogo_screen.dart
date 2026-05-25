// lib/presentation/screens/jogo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/models/game_state.dart';
import '../../../data/services/pergunta_service.dart';
import '../../../data/services/jogo_flow_service.dart';
import '../../../data/services/jogo_voice_service.dart';
import '../../../core/enums/nivel_enum.dart';
import '../../../core/theme/app_colors.dart';

import '../widgets/jogo/area_pergunta.dart';
import '../widgets/jogo/hud_widget.dart';
// Removido: ProgressWidget (não será mais usado pois a info está no HUD)

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
  final FocusNode _botaoComecarFocusNode = FocusNode();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _botaoComecarFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _flow.dispose();
    _voice.pararTudo();
    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _botaoComecarFocusNode.dispose();
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
        HapticFeedback.lightImpact();
        context.read<GameState>().registrarAcerto(tempoRestante: _flow.tempoRestante, ehModoDisputa: widget.isModoDisputa);
        _flow.processarAcerto(onConcluirFase: () => _mostrarDialogo(true));
        _garantirFoco();
      },
      onErro: (correta) {
        HapticFeedback.heavyImpact();
        _flow.pausarJogo();
        _mostrarDialogo(false, correta: correta);
      },
    );
  }

  void _mostrarDialogo(bool isFimFase, {String correta = ""}) {
    final gs = context.read<GameState>();
    final bool ehFinalAbsoluto = isFimFase && gs.nivelAtual == Nivel.mestre;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FocusScope(
        autofocus: true,
        child: AlertDialog(
          title: Text(ehFinalAbsoluto ? "👑🏆 CONQUISTA MÁXIMA!" : (isFimFase ? "🎉 Parabéns!" : "❌ Ops!")),
          content: Text(
            ehFinalAbsoluto
                ? "👑🏆 INCRÍVEL! Você completou todos os níveis! 🏆👑"
                : (isFimFase
                    ? "🎉 Parabéns!\nVocê passou de fase! 🚀"
                    : "❌ Ops! A resposta correta era: $correta"),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              autofocus: true,
              onPressed: () {
                Navigator.pop(context);
                if (ehFinalAbsoluto) Navigator.of(context).pushReplacementNamed('/home_view');
                else _confirmarDialogo(isFimFase);
              },
              child: Text(isFimFase ? "CONTINUAR" : "TENTAR NOVAMENTE"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarDialogo(bool isFimFase) {
    final gs = context.read<GameState>();
    isFimFase ? gs.concluirEAvancarFase() : gs.resetarNivelParaInicio();
    _flow.iniciarDesafio(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    _garantirFoco();
  }

  void _toggleMicrofone() {
    _voice.acionarMicrofone(jogoAtivo: _flow.jogoAtivo, onTextoCapturado: (t) {
      setState(() => _respostaController.text = t);
      _executarValidacao();
    }, onFinalizado: () {});
  }

  void _exibirDica() {
    showDialog(
      context: context,
      builder: (_) => FocusScope(
        autofocus: true,
        child: AlertDialog(
          title: const Text("Dica do Cal! 💡"),
          content: Text(_flow.perguntaAtual?.dica ?? "Analise com calma!"),
          actions: [
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendi!"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/${widget.perfil}.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => 
                  Image.asset('assets/images/fundo_jogo.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                  IconButton(icon: Icon(gs.acessibilidadeVoz ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 30), onPressed: () => gs.alternarAcessibilidadeVoz()),
                ]),
                
                const SizedBox(height: 245), 
                
                HUDWidget(state: gs, isDisputa: _flow.disputaAtiva, tempoRestante: _flow.tempoRestante),
                
                // ProgressWidget removido para limpar a tela
                
                const Spacer(),
                
                if (!_flow.jogoAtivo)
                  Center(
                    child: Focus(
                      focusNode: _botaoComecarFocusNode,
                      onKey: (node, event) {
                        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                          _iniciarJogo();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: ElevatedButton(
                        onPressed: _iniciarJogo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("COMEÇAR", style: TextStyle(fontSize: 28, color: Colors.white)),
                      ),
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

          Positioned(
            bottom: 120, right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _exibirDica,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Dica", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ),
                ),
                GestureDetector(
                  onTap: _exibirDica,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 25, spreadRadius: 8),
                      ],
                    ),
                    child: Image.asset('assets/images/mascote_cal.png', width: 144, height: 144, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}