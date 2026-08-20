// lib/presentation/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matematicadivertida/l10n/app_localizations.dart';

import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';
import '../../data/models/game_state.dart';
import '../widgets/perfil/perfil_card.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _estaSilenciado = false;
  String _modo = "Treino";

  @override
  void initState() {
    super.initState();
    _iniciarAudio();
  }

  void _iniciarAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sons/Subindo_de_nível.mp3'));
    } catch (e) {
      debugPrint("Erro ao tocar música de fundo: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String modoCru = args?['modo'] ?? "treino";
    _modo = modoCru.toLowerCase().contains('disputa') ? "Disputa 🏆" : "Treino";
  }

  void _selecionarPerfil(String perfil) async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final gs = context.read<GameState>();
    
    // Pega o nome mais atualizado diretamente do AuthController (onde o apelido editado foi salvo)
    final String nomeAtualizado = auth.nomeJogador;

    gs.definirPerfil(perfil); 
    
    await auth.escolherPerfilParaJogar(
      nome: nomeAtualizado, 
      perfilEscolhido: perfil,
    );

    if (mounted) {
      final bool verificaDisputa = _modo.toLowerCase().contains('disputa');
      Navigator.of(context).pushReplacementNamed('/jogo', arguments: {
        'nome': nomeAtualizado,
        'perfil': perfil,
        'modo': verificaDisputa ? 'disputa' : 'treino',
        'isModoDisputa': verificaDisputa,
        'disputa': verificaDisputa,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';
    
    // Nome exibido dinâmico vindo direto da fonte da verdade
    final String nomeExibicao = auth.nomeJogador.isNotEmpty ? auth.nomeJogador : "Francisco";

    final larguraTela = MediaQuery.of(context).size.width;
    final larguraCard = (larguraTela > 500 ? 230.0 : (larguraTela - 52) / 2);

    return Scaffold(
      backgroundColor: const Color(0xFF532287),
      body: Stack(
        children: [
          // 1. FUNDO ROXO MÁGICO COM ELEMENTOS FLUTUANTES
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

          // 2. CONTEÚDO CENTRALIZADO E HARMÔNICO NA VERTICAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CABEÇALHO REFINADO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eIngles ? "Hello, $nomeExibicao!" : "Olá, $nomeExibicao!",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    eIngles ? "Mode: ${_modo.contains('Disputa') ? 'Challenge 🏆' : 'Practice'}" : "Modo: $_modo",
                                    style: GoogleFonts.poppins(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(_estaSilenciado ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 26),
                                  onPressed: () {
                                    setState(() => _estaSilenciado = !_estaSilenciado);
                                    _estaSilenciado ? _audioPlayer.pause() : _audioPlayer.resume();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home_view'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TÍTULO DA SEÇÃO
                      Text(
                        eIngles ? "Choose your Profile to Play" : "Escolha seu Perfil para Jogar",
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          shadows: [const Shadow(color: Colors.black45, blurRadius: 6)],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // WRAP CENTRALIZADO COM OS CARDS PROPORCIONAIS
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: larguraCard,
                            child: _buildCardComEfeito(
                              eIngles ? "KID (BOY)" : "CRIANÇA (MENINO)", 
                              "assets/images/menino.png", 
                              () => _selecionarPerfil("crianca"), 
                              Colors.cyanAccent
                            ),
                          ),
                          SizedBox(
                            width: larguraCard,
                            child: _buildCardComEfeito(
                              eIngles ? "KID (GIRL)" : "CRIANÇA (MENINA)", 
                              "assets/images/menina.png", 
                              () => _selecionarPerfil("crianca"), 
                              Colors.pinkAccent
                            ),
                          ),
                          SizedBox(
                            width: larguraCard,
                            child: _buildCardComEfeito(
                              eIngles ? "ADULT MODE" : "MODO ADULTO", 
                              "assets/images/perfil_adulto.png", 
                              () => _selecionarPerfil("adulto"), 
                              Colors.amberAccent
                            ),
                          ),
                          SizedBox(
                            width: larguraCard,
                            child: _buildCardComEfeito(
                              eIngles ? "TEACHER MODE" : "MODO PROFESSOR", 
                              "assets/images/perfil_professor.png", 
                              () => _selecionarPerfil("professor"), 
                              Colors.greenAccent
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardComEfeito(String label, String img, VoidCallback onTap, Color corNeon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: corNeon.withOpacity(0.35),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PerfilCard(label: label, img: img, onTap: onTap),
        ),
      ),
    );
  }
}