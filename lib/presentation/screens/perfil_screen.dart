// lib/presentation/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String _nomeUsuario = "";
  String _modo = "";

  @override
  void initState() {
    super.initState();
    _iniciarAudio();
  }

  Future<void> _iniciarAudio() async {
    try {
      // Configura para tocar em loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Carrega o asset de forma explícita
      await _audioPlayer.play(AssetSource('sons/subindo_de_nivel.mp3'));
      
      if (mounted) {
        setState(() => _estaSilenciado = false);
      }
    } catch (e) {
      // No Web, o autoplay pode ser bloqueado pelo navegador se o usuário não tiver interagido com a página
      debugPrint("Erro ao tocar áudio (comum no Web se não houver interação): $e");
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
    _nomeUsuario = args?['nome'] ?? "Visitante";
    final String modoCru = args?['modo'] ?? "treino";
    _modo = modoCru.toLowerCase().contains('disputa') ? "Disputa 🏆" : "Treino";
  }

  void _selecionarPerfil(String perfil) async {
    final gs = context.read<GameState>();
    gs.definirPerfil(perfil); 
    
    await Provider.of<AuthController>(context, listen: false).escolherPerfilParaJogar(
      nome: _nomeUsuario, perfilEscolhido: perfil,
    );

    if (mounted) {
      final bool verificaDisputa = _modo.toLowerCase().contains('disputa');
      Navigator.of(context).pushReplacementNamed('/jogo', arguments: {
        'nome': _nomeUsuario,
        'perfil': perfil,
        'modo': verificaDisputa ? 'disputa' : 'treino',
        'isModoDisputa': verificaDisputa,
        'disputa': verificaDisputa,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png', 
              fit: BoxFit.cover, 
              alignment: Alignment.center,
            ),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.38), Colors.transparent, Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.45),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(text: "Olá ", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                                            TextSpan(text: _nomeUsuario, style: GoogleFonts.orbitron(color: const Color(0xFFFF5A5A), fontSize: 24, fontWeight: FontWeight.w800)),
                                          ]),
                                        ),
                                        Text("Você está no modo $_modo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(_estaSilenciado ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 30),
                                  onPressed: () {
                                    setState(() => _estaSilenciado = !_estaSilenciado);
                                    _estaSilenciado ? _audioPlayer.pause() : _audioPlayer.resume();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home_view'),
                                ),
                              ],
                            ),

                            const Spacer(),

                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Wrap(
                                  spacing: 20, 
                                  runSpacing: 20, 
                                  alignment: WrapAlignment.center,
                                  children: [
                                    PerfilCard(label: "CRIANÇA (MENINO)", img: "assets/images/menino.png", onTap: () => _selecionarPerfil("crianca")),
                                    PerfilCard(label: "CRIANÇA (MENINA)", img: "assets/images/menina.png", onTap: () => _selecionarPerfil("crianca")),
                                    PerfilCard(label: "MODO ADULTO", img: "assets/images/perfil_adulto.png", onTap: () => _selecionarPerfil("adulto")),
                                    PerfilCard(label: "MODO PROFESSOR", img: "assets/images/perfil_professor.png", onTap: () => _selecionarPerfil("professor")),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}