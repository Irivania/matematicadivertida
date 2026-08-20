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
          _voice.acionarMicrofone(
            jogoController: context.read<JogoController>(),
            gameState: gs,
            jogoAtivo: _flow.jogoAtivo,
            onTextoCapturado: (textoReconhecido) {
              if (mounted && _flow.jogoAtivo) {
                setState(() { _respostaController.text = textoReconhecido; });
                _executarValidacao();
              }
            },
            onFinalizado: () {},
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
                    : (ehFimDeNivel ? {"tit": "Nível Superado! 🎖️", "msg": "Sua evolução é notável. Prepare-se para o próximo nivel!"} 
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

  void _reiniciarPartidaDoZero() {
    final gs = context.read<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eIngles ? "Restart Game?" : "Reiniciar Jogo?"),
        content: Text(eIngles 
            ? "Your current progress will be lost. Do you want to start over?" 
            : "Seu progresso atual será perdido. Deseja começar do zero?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(eIngles ? "Cancel" : "Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              gs.reiniciarJogoAtual(); // Reseta os dados e limpa SharedPreferences
              _iniciarJogo(); // Inicia o jogo limpo
            },
            child: Text(eIngles ? "Restart" : "Reiniciar", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF8F9FA),
          title: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 28),
              const SizedBox(width: 8),
              const Text("Dica do Cal! 💡", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(_flow.perguntaAtual?.dica ?? "Analise com calma!", style: const TextStyle(color: Colors.black54, fontSize: 16)),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context), 
                child: const Text("Entendi!", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    ).then((_) => _garantirFocoPergunta());
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o GameState global para redesenhar a tela ao mudar o idioma
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    final larguraTela = MediaQuery.of(context).size.width;
    final bool eCelular = larguraTela < 768;

    if (!_flow.jogoAtivo && !_exibindoMensagem && !_menuButtonFocusNode.hasFocus) _garantirFocoMenu();

    return Scaffold(
      backgroundColor: const Color(0xFF532287),
      body: Stack(
        children: [
          // 1. FUNDO ROXO MÁGICO UNIFICADO PARA TODOS OS PERFIS
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8A49C9), Color(0xFF532287), Color(0xFF221133)],
                ),
              ),
              child: Stack(
                children: List.generate(8, (i) => Positioned(
                  left: (i * 50.0) % 300, top: (i * 80.0) % 600,
                  child: Icon(Icons.calculate_outlined, color: Colors.white.withOpacity(0.06), size: 60),
                )),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 2. CABEÇALHO COMPACTO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _voice.alternarAcessibilidade(
                              jogoController: context.read<JogoController>(),
                              gameState: gs,
                              jogoAtivo: _flow.jogoAtivo,
                              perguntaAtual: _flow.perguntaAtual?.pergunta,
                              onRelerPergunta: () => _falarPerguntaAtualSeAtivo(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Icon(gs.acessibilidadeAtiva ? Icons.volume_up : Icons.volume_off, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 3. LOGO MAIOR NO TOPO
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _flow.jogoAtivo ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: Column(
                    children: [
                      Image.asset('assets/images/logo_matematica.png', height: eCelular ? 170 : 220, fit: BoxFit.contain),
                      const SizedBox(height: 2),
                      Text(
                        eIngles ? "Ready for today's challenge?" : "Pronto para o desafio de hoje?", 
                        style: const TextStyle(color: Colors.white70, fontSize: 17, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  secondChild: Image.asset('assets/images/logo_matematica.png', height: eCelular ? 130 : 170, fit: BoxFit.contain),
                ),
                
                // CARD DE STATUS
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: _flow.jogoAtivo ? 4 : 10),
                  padding: EdgeInsets.all(_flow.jogoAtivo ? 8 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: const Color(0xFFF1F5F9),
                    ),
                    child: CabecalhoJogoWidget(gs: gs, disputaAtiva: _flow.disputaAtiva, tempoRestante: _flow.displayTempo),
                  ),
                ),
                
                // 4. ÁREA DE PERGUNTAS ALINHADA AO TOPO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!_flow.jogoAtivo && !_exibindoMensagem)
                          Expanded(
                            child: Center(
                              child: MenuInicialWidget(
                                temPartidaSalva: gs.temPartidaSalva,
                                menuButtonFocusNode: _menuButtonFocusNode,
                                onContinuar: _continuarPartida,
                                onIniciar: _iniciarJogo,
                                onReiniciar: _reiniciarPartidaDoZero,
                              ),
                            ),
                          )
                        else if (_flow.jogoAtivo)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: AreaPerguntaWidget(
                              key: ValueKey(_flow.perguntaAtual?.pergunta),
                              perguntaAtual: _flow.perguntaAtual,
                              jogoAtivo: _flow.jogoAtivo,
                              disputaAtiva: _flow.disputaAtiva,
                              controller: _respostaController,
                              focusNode: _respostaFocusNode,
                              onValidar: _executarValidacao,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. MASCOTE CAL
          if (_flow.jogoAtivo)
            Positioned(
              bottom: 15,
              right: 16,
              child: Transform.scale(
                scale: 0.55,
                child: MascoteDicaWidget(onExibirDica: _exibirDica),
              ),
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