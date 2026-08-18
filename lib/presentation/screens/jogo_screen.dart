// lib/presentation/screens/jogo_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/models/game_state.dart';
import '../../../data/services/pergunta_service.dart';
import '../../../data/services/jogo_flow_service.dart';
import '../../../data/services/jogo_voice_service.dart';
import '../controllers/jogo_controller.dart';
import '../widgets/jogo/area_pergunta.dart';
import '../widgets/jogo/cabecalho_jogo_widget.dart';
import '../widgets/jogo/menu_inicial_widget.dart';
import '../widgets/jogo/mensagem_dialog_widget.dart';
import '../widgets/jogo/mascote_dica_widget.dart';
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
    _voice = JogoVoiceService();
  }

  @override
  void dispose() {
    _flow.dispose();
    try {
      Provider.of<JogoController>(context, listen: false).pararMicrofone();
      Provider.of<JogoController>(context, listen: false).pararTTS();
    } catch (_) {}

    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _menuButtonFocusNode.dispose();
    super.dispose();
  }

  void _garantirFocoPergunta() => Future.microtask(() { if (mounted) _respostaFocusNode.requestFocus(); });
  void _garantirFocoMenu() => Future.microtask(() { if (mounted) _menuButtonFocusNode.requestFocus(); });

  void _falarPerguntaAtualSeAtivo() {
    if (_flow.perguntaAtual == null) return;
    final gs = context.read<GameState>();
    if (gs.acessibilidadeAtiva) {
      _voice.iniciarLeituraPergunta(
        jogoController: context.read<JogoController>(),
        gameState: gs,
        pergunta: _flow.perguntaAtual!.pergunta,
        jogoAtivo: _flow.jogoAtivo,
        onAcionarMicrofone: () {
          // LÓGICA DE VOZ AJUSTADA PARA NORMALIZAR A RESPOSTA
          _voice.ouvirResposta(
            jogoController: context.read<JogoController>(),
            onResultado: (textoReconhecido) {
              if (mounted && _flow.jogoAtivo) {
                // Remove pontuação e espaços extras para garantir validação correta
                String respostaLimpa = textoReconhecido.trim().toLowerCase().replaceAll(RegExp(r'[.,!?-]'), '');
                
                setState(() {
                  _respostaController.text = respostaLimpa;
                });
                
                // Valida automaticamente após processar a voz
                _executarValidacao();
              }
            },
          );
        },
      );
    }
  }

  void _mostrarDialogo(bool isFimFase) {
    if (!mounted) return;
    final gs = context.read<GameState>();
    isFimFase ? _flow.pausarDefinitivo() : _flow.pausarJogo();

    final bool ehFimDeJogo = isFimFase && gs.nivelAtual == Nivel.mestre && gs.fase == 5; 
    final bool ehFimDeNivel = isFimFase && !ehFimDeJogo && gs.fase == 1; 

    final msgsErro = [
      {"tit": "Quase lá! 🧐", "msg": "Essa foi difícil, mas você está aprendendo muito! Vamos tentar de novo?"},
      {"tit": "Não desista! 💪", "msg": "Grandes matemáticos erram. Respire fundo e vamos tentar de novo!"},
    ];

    final escolha = isFimFase 
        ? (ehFimDeJogo ? {"tit": "Você é uma Lenda! 👑", "msg": "Você superou todos os desafios! Parabéns, Mestre Supremo!"} 
                      : (ehFimDeNivel ? {"tit": "Nível Superado! 🎖️", "msg": "Sua evolução é notável. Prepare-se para o próximo nível!"} 
                                      : {"tit": "Fase Concluída! 🚀", "msg": "Você dominou esta etapa! Vamos para a próxima?"}))
        : (msgsErro..shuffle()).first;

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
    _falarPerguntaAtualSeAtivo();
    Future.delayed(const Duration(milliseconds: 150), () => _garantirFocoPergunta());
  }

  void _iniciarJogo() {
    if (_flow.jogoAtivo) return;
    context.read<GameState>().limparProgresso();
    _flow.iniciarDesafio(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    _falarPerguntaAtualSeAtivo();
    _garantirFocoPergunta();
  }

  void _continuarPartida() {
    context.read<GameState>().carregarProgresso();
    _flow.continuarPartida();
    _falarPerguntaAtualSeAtivo();
    _garantirFocoPergunta();
  }

  void _executarValidacao() {
    final gs = context.read<GameState>();
    _flow.validarResposta(
      onAcerto: () {
        HapticFeedback.lightImpact();
        gs.registrarAcerto(tempoRestante: _flow.displayTempo, ehModoDisputa: widget.isModoDisputa);
        _flow.processarAcerto(onConcluirFase: () => _mostrarDialogo(true));
        if (!_exibindoMensagem) _falarPerguntaAtualSeAtivo();
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
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendi!")),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                    IconButton(
                      icon: Icon(gs.acessibilidadeAtiva ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 30),
                      onPressed: () {
                        _voice.alternarAcessibilidade(
                          jogoController: context.read<JogoController>(),
                          gameState: gs,
                          jogoAtivo: _flow.jogoAtivo,
                          perguntaAtual: _flow.perguntaAtual?.pergunta,
                          onRelerPergunta: () => _falarPerguntaAtualSeAtivo(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 250),
                CabecalhoJogoWidget(gs: gs, disputaAtiva: _flow.disputaAtiva, tempoRestante: _flow.displayTempo),
                const Spacer(),
                if (!_flow.jogoAtivo && !_exibindoMensagem)
                  MenuInicialWidget(
                    temPartidaSalva: gs.temPartidaSalva,
                    menuButtonFocusNode: _menuButtonFocusNode,
                    onContinuar: _continuarPartida,
                    onIniciar: _iniciarJogo,
                  )
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
          Positioned(
            bottom: !widget.isModoDisputa ? MediaQuery.of(context).size.height * 0.15 : 20.0,
            right: 20,
            child: MascoteDicaWidget(onExibirDica: _exibirDica),
          ),
          if (_exibindoMensagem)
            MensagemDialogWidget(
              titulo: _tituloMsg,
              conteudo: _conteudoMsg,
              focusNode: _menuButtonFocusNode,
              onContinuar: () => _confirmarDialogo(_msgEhFimFase),
            ),
        ],
      ),
    );
  }
}