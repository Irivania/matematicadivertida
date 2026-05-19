import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:matematicadivertida/core/theme/app_colors.dart';
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _nomeController = TextEditingController();
  String _nomeUsuario = "";
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _estaSilenciado = false;

  @override
  void initState() {
    super.initState();
    _iniciarTrilhaSonora();
    _nomeController.addListener(() {
      setState(() {
        _nomeUsuario = _nomeController.text;
      });
    });
  }

  void _iniciarTrilhaSonora() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sons/Subindo_de_nível.mp3'));
    } catch (e) {
      debugPrint("Não foi possível carregar a trilha sonora: $e");
    }
  }

  void _alternarSilenciar() async {
    setState(() {
      _estaSilenciado = !_estaSilenciado;
    });

    if (_estaSilenciado) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _campoNomeUsuario({TextAlign textAlign = TextAlign.start}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (textAlign != TextAlign.center)
            const Text(
              "QUAL É O SEU NOME?",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          if (textAlign != TextAlign.center) const SizedBox(height: 8),
          TextField(
            controller: _nomeController,
            textAlign: textAlign,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Digite seu nome...",
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: textAlign == TextAlign.center
                  ? null
                  : const Icon(Icons.person_outline, color: Colors.white70, size: 20),
              fillColor: Colors.black.withValues(alpha: 0.4),
              filled: true,
              contentPadding: textAlign == TextAlign.center
                  ? const EdgeInsets.symmetric(vertical: 12, horizontal: 16)
                  : const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final alturaTela = MediaQuery.of(context).size.height;
    final bool eTelaLarga = largura > 900;

    int colunas = 4;

    if (largura < 1200 && largura > 900) {
      colunas = 2;
    }
    if (largura <= 900 && largura > 600) {
      colunas = 2;
    }
    if (largura <= 600) {
      colunas = 1;
    }

    String mensagemBoasVindas = _nomeUsuario.trim().isEmpty
        ? "QUEM VAI JOGAR HOJE?"
        : "OLÁ, ${_nomeUsuario.toUpperCase()}!";

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // FUNDO
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ESCURECIMENTO
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.30),
            ),
          ),

          // CONTEÚDO
          SafeArea(
            child: SizedBox(
              width: largura,
              height: alturaTela,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 40,
                    top: eTelaLarga ? (alturaTela * 0.25) : 80,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: eTelaLarga ? 1400 : 600,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          eTelaLarga
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LADO ESQUERDO
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 50),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              mensagemBoasVindas,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.5,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: 360,
                                              child: Text(
                                                "Digite seu nome e escolha um perfil para começar sua aventura matemática.",
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.82),
                                                  fontSize: 15,
                                                  height: 1.5,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 28),
                                            // INPUT
                                            _campoNomeUsuario(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    // CARDS
                                    Expanded(
                                      flex: 6,
                                      child: Transform.translate(
                                        offset: const Offset(-220, 220),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildGridCards(
                                            colunas,
                                            _nomeUsuario,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      mensagemBoasVindas,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Digite seu nome e escolha um perfil para começar.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    _campoNomeUsuario(textAlign: TextAlign.center),
                                    const SizedBox(height: 40),
                                    _buildGridCards(
                                      colunas,
                                      _nomeUsuario,
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // BOTÃO VOLUME
          Positioned(
            top: 20,
            right: 80,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  _estaSilenciado ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _alternarSilenciar,
              ),
            ),
          ),

          // BOTÃO SAIR
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  try {
                    await Provider.of<AuthController>(
                      context,
                      listen: false,
                    ).logout();
                  } catch (e) {
                    debugPrint("Erro ao deslogar: $e");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCards(int colunas, String nomeJogador) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: colunas,
      childAspectRatio: 0.82,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _CardPerfilAnimado(
          nomeJogador: nomeJogador,
          labelExibicao: "MENINO",
          perfilLogico: "crianca",
          imagem: "assets/images/menino.png",
          neonColor: AppColors.neonCiano,
        ),
        _CardPerfilAnimado(
          nomeJogador: nomeJogador,
          labelExibicao: "MENINA",
          perfilLogico: "crianca",
          imagem: "assets/images/menina.png",
          neonColor: const Color(0xFFC040FF),
        ),
        _CardPerfilAnimado(
          nomeJogador: nomeJogador,
          labelExibicao: "ADULTO",
          perfilLogico: "adulto",
          imagem: "assets/images/perfil_adulto.png",
          neonColor: const Color(0xFFFFD700),
        ),
        _CardPerfilAnimado(
          nomeJogador: nomeJogador,
          labelExibicao: "PROFESSOR",
          perfilLogico: "professor",
          imagem: "assets/images/perfil_professor.png",
          neonColor: AppColors.neonVerde,
        ),
      ],
    );
  }
}

class _CardPerfilAnimado extends StatefulWidget {
  final String nomeJogador;
  final String labelExibicao;
  final String perfilLogico;
  final String imagem;
  final Color neonColor;

  const _CardPerfilAnimado({
    required this.nomeJogador,
    required this.labelExibicao,
    required this.perfilLogico,
    required this.imagem,
    required this.neonColor,
  });

  @override
  State<_CardPerfilAnimado> createState() => _CardPerfilAnimadoState();
}

class _CardPerfilAnimadoState extends State<_CardPerfilAnimado>
    with SingleTickerProviderStateMixin {
  double _escala = 1.0;
  bool _isHovered = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selecionarPerfil() async {
    if (widget.nomeJogador.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite seu nome para continuar."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.neonCiano,
        ),
      ),
    );

    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );

      // CORRIGIDO: Passando os parâmetros exatos aceitos pela assinatura do seu método de negócio
      await authController.escolherPerfilParaJogar(
        nome: widget.nomeJogador.trim(),
        perfilEscolhido: widget.perfilLogico,
      );

      if (mounted) {
        Navigator.pop(context); // Remove o loading dialog
        Navigator.of(context).pushReplacementNamed('/home_view');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove o loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar perfil: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: true,
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _escala = 1.05;
          _isHovered = true;
        });
        _animationController.repeat(reverse: true);
      },
      onExit: (_) {
        setState(() {
          _escala = 1.0;
          _isHovered = false;
        });
        _animationController.stop();
        _animationController.reset();
      },
      child: SizedBox.expand(
        child: GestureDetector(
          onTap: _selecionarPerfil,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final movimento = sin(_animationController.value * 2 * pi) * 6;

              return Transform.translate(
                offset: Offset(0, movimento),
                child: AnimatedScale(
                  scale: _escala,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: child,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? widget.neonColor : widget.neonColor.withValues(alpha: 0.5),
                  width: 2.5,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.neonColor.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 38.0,
                        top: 12.0,
                        left: 8,
                        right: 8,
                      ),
                      child: Image.asset(
                        widget.imagem,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Text(
                        widget.labelExibicao,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}