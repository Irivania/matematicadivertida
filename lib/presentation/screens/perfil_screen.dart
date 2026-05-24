// lib/presentation/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';
import '../../data/models/game_state.dart';
import '../widgets/perfil/perfil_card.dart'; // Importação do seu novo componente isolado

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

  void _iniciarAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('sons/Subindo_de_nível.mp3'));
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

  // Lógica central de seleção mantida
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
      body: Stack(
        children: [
          // FUNDO
          Positioned.fill(
            child: Image.asset('assets/images/fundo_imagem_perfil.png', 
                fit: BoxFit.cover, alignment: Alignment.topCenter),
          ),
          
          // OVERLAY ESCURO
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

          // BOTÃO SOM
          Positioned(
            top: 20, right: 80,
            child: IconButton(
              icon: Icon(_estaSilenciado ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 35),
              onPressed: () {
                setState(() => _estaSilenciado = !_estaSilenciado);
                _estaSilenciado ? _audioPlayer.pause() : _audioPlayer.resume();
              },
            ),
          ),

          // BOTÃO VOLTAR
          Positioned(
            top: 20, right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 35),
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home_view'),
            ),
          ),

          // INFORMAÇÕES DO JOGADOR
          Positioned(
            top: 28, left: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                      TextSpan(text: "Olá ", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                      TextSpan(text: _nomeUsuario, style: GoogleFonts.orbitron(color: const Color(0xFFFF5A5A), fontSize: 30, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  Text("Você está no modo $_modo", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // CARDS (Agora limpos e organizados)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Wrap(
                spacing: 28, runSpacing: 28, alignment: WrapAlignment.center,
                children: [
                  PerfilCard(label: "CRIANÇA (MENINO)", img: "assets/images/menino.png", onTap: () => _selecionarPerfil("crianca")),
                  PerfilCard(label: "CRIANÇA (MENINA)", img: "assets/images/menina.png", onTap: () => _selecionarPerfil("crianca")),
                  PerfilCard(label: "MODO ADULTO", img: "assets/images/perfil_adulto.png", onTap: () => _selecionarPerfil("adulto")),
                  PerfilCard(label: "MODO PROFESSOR", img: "assets/images/perfil_professor.png", onTap: () => _selecionarPerfil("professor")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}