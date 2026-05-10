import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final alturaTela = MediaQuery.of(context).size.height;

    int colunas = 4;
    if (largura < 1200) colunas = 2;
    if (largura < 700) colunas = 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: largura,
              height: alturaTela,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 340),
                      const Text(
                        "ESCOLHA O PERFIL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(blurRadius: 15, color: Colors.black, offset: Offset(0, 5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: colunas,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 25,
                            children: [
                              _CardPerfilAnimado(perfil: "crianca", imagem: "assets/images/menino.png", neonColor: const Color(0xFFFFD700)),
                              _CardPerfilAnimado(perfil: "crianca", imagem: "assets/images/menina.png", neonColor: const Color(0xFFC040FF)),
                              _CardPerfilAnimado(perfil: "adulto", imagem: "assets/images/adulto1.png", neonColor: const Color(0xFF00CFFF)),
                              _CardPerfilAnimado(perfil: "professor", imagem: "assets/images/professor1.png", neonColor: const Color(0xFF39FF14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
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
}

// Transformamos o Card em um StatefulWidget para gerenciar o estado do Hover
class _CardPerfilAnimado extends StatefulWidget {
  final String perfil;
  final String imagem;
  final Color neonColor;

  const _CardPerfilAnimado({
    required this.perfil,
    required this.imagem,
    required this.neonColor,
  });

  @override
  State<_CardPerfilAnimado> createState() => _CardPerfilAnimadoState();
}

class _CardPerfilAnimadoState extends State<_CardPerfilAnimado> {
  double _escala = 1.0; // Escala padrão

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      // Quando o mouse entra, aumenta a escala em 5%
      onEnter: (_) => setState(() => _escala = 1.05),
      // Quando o mouse sai, volta ao tamanho original
      onExit: (_) => setState(() => _escala = 1.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.jogo, arguments: widget.perfil),
        child: AnimatedScale(
          scale: _escala,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack, // Efeito leve de "mola" ao crescer
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: widget.neonColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.4),
                  blurRadius: _escala > 1.0 ? 25 : 15, // Brilha mais no hover
                  spreadRadius: _escala > 1.0 ? 2 : 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(widget.imagem, fit: BoxFit.cover, alignment: Alignment.topCenter),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.neonColor.withOpacity(0.15),
                            Colors.transparent,
                            widget.neonColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}