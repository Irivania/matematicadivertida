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
import '../../../core/enums/nivel_enum.dart'; 

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
  
  bool _exibindoMensagem = false;
  String _tituloMsg = "";
  String _conteudoMsg = "";
  bool _msgEhFimFase = false;

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

  void _garantirFocoPergunta() => Future.microtask(() {
    if (mounted) _respostaFocusNode.requestFocus();
  });

  void _garantirFocoMenu() => Future.microtask(() {
    if (mounted) _menuButtonFocusNode.requestFocus();
  });

  void _mostrarDialogo(bool isFimFase) {
    if (!mounted) return;
    final gs = context.read<GameState>();
    
    // Pausa o fluxo para garantir que o tempo pare no final
    isFimFase ? _flow.pausarDefinitivo() : _flow.pausarJogo();

    final bool ehFimDeJogo = isFimFase && gs.nivelAtual == Nivel.mestre && gs.fase == 5; 
    final bool ehFimDeNivel = isFimFase && !ehFimDeJogo && gs.fase == 1; 

    final msgFinal = {"tit": "Você é uma Lenda! 👑", "msg": "Você superou todos os desafios! Parabéns, Mestre Supremo!"};
    final msgNivel = {"tit": "Nível Superado! 🎖️", "msg": "Sua evolução é notável. Prepare-se, o próximo nível é mais desafiador!"};
    final msgFase = {"tit": "Fase Concluída! 🚀", "msg": "Você dominou esta etapa! Vamos para a próxima?"};
    final msgsErro = [
      {"tit": "Quase lá! 🧐", "msg": "Essa foi difícil, mas você está aprendendo muito! Vamos recomeçar?"},
      {"tit": "Não desista! 💪", "msg": "Grandes matemáticos erram. Respire fundo e vamos tentar de novo!"},
    ];

    final escolha = isFimFase 
        ? (ehFimDeJogo ? msgFinal : (ehFimDeNivel ? msgNivel : msgFase))
        : (msgsErro..shuffle()).first;

    // Busca a medalha se for fim de nível
    String medalha = (isFimFase && !ehFimDeJogo) ? gs.obterTipoMedalha(gs.nivelAtual.name) : "";

    setState(() {
      _exibindoMensagem = true;
      _msgEhFimFase = isFimFase;
      _tituloMsg = escolha["tit"]!;
      _conteudoMsg = "${escolha["msg"]!}${medalha.isNotEmpty ? '\n\nConquista: $medalha' : ''}";
    });
    _garantirFocoMenu();
  }

  void _confirmarDialogo(bool isFimFase) {
    setState(() => _exibindoMensagem = false);
    if (isFimFase) {
      context.read<GameState>().concluirEAvancarFase();
      _flow.gerarPergunta();
    } else {
      _flow.retomarJogo();
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _garantirFocoPergunta();
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
    final gs = context.read<GameState>();
    _flow.validarResposta(
      onAcerto: () {
        HapticFeedback.lightImpact();
        gs.registrarAcerto(tempoRestante: _flow.displayTempo, ehModoDisputa: widget.isModoDisputa);
        _flow.processarAcerto(onConcluirFase: () => _mostrarDialogo(true));
      },
      onErro: (correta) {
        HapticFeedback.heavyImpact();
        _flow.pausarJogo();
        _respostaController.clear();
        if (widget.isModoDisputa) gs.resetarNivelParaInicioDoNivel();
        else gs.resetarPerguntaParaPrimeira();
        _flow.gerarPergunta();
        _mostrarDialogo(false);
      },
    );
  }

  void _exibirDica() {
    final FocusNode dicaFocusNode = FocusNode();
    showDialog(
      context: context,
      builder: (_) {
        Future.microtask(() => dicaFocusNode.requestFocus());
        return AlertDialog(
          title: const Text("Dica do Cal! 💡"),
          content: Text(_flow.perguntaAtual?.dica ?? "Analise com calma!"),
          actions: [
            Focus(
              focusNode: dicaFocusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                  Navigator.pop(context);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("Entendi!"),
              ),
            ),
          ],
        );
      },
    ).then((_) => _garantirFocoPergunta());
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    if (!_flow.jogoAtivo && !_exibindoMensagem && !_menuButtonFocusNode.hasFocus) _garantirFocoMenu();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: FittedBox(fit: BoxFit.cover, alignment: Alignment.topCenter, child: Image.asset('assets/images/${widget.perfil}.png'))),
          SafeArea(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                  IconButton(icon: Icon(gs.acessibilidadeAtiva ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 30), onPressed: () => gs.alternarAcessibilidadeVoz()),
                ]),
                const SizedBox(height: 250),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                          const SizedBox(width: 8),
                          Text(gs.nomeNivelExibicao, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      HUDWidget(state: gs, isDisputa: _flow.disputaAtiva, tempoRestante: _flow.displayTempo),
                      const Divider(color: Colors.white24, height: 20),
                      Text("Pergunta ${gs.indicePerguntaAtual} de ${gs.maxPerguntasPorFase}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                if (!_flow.jogoAtivo && !_exibindoMensagem)
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
                else if (_flow.jogoAtivo)
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
            bottom: !widget.isModoDisputa ? MediaQuery.of(context).size.height * 0.15 : 20.0,
            right: 20,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Text("Dica?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.1),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: GestureDetector(
                    onTap: _exibirDica,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.asset('assets/images/mascote_cal.png', width: 150),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_exibindoMensagem)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_tituloMsg, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text(_conteudoMsg, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 30),
                      Focus(
                        focusNode: _menuButtonFocusNode,
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                            _confirmarDialogo(_msgEhFimFase);
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: ElevatedButton(
                          onPressed: () => _confirmarDialogo(_msgEhFimFase),
                          child: const Text("CONTINUAR", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ]),
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