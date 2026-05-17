import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:matematicadivertida/core/theme/app_colors.dart';
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart'; 

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final alturaTela = MediaQuery.of(context).size.height;

    // Lógica de colunas responsiva
    int colunas = 4;
    if (largura < 1200) colunas = 2;
    if (largura < 700) colunas = 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // 1. FUNDO DA TELA
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.backgroundEscuro),
            ),
          ),

          // 2. CONTEÚDO PRINCIPAL (Movido para trás do botão no Stack)
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
                      SizedBox(height: alturaTela * 0.35),
                      const Text(
                        "ESCOLHA SEU AVATAR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(blurRadius: 15, color: AppColors.neonCiano),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // GRID DE SELEÇÃO
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: colunas,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 25,
                            children: const [
                              _CardPerfilAnimado(
                                labelExibicao: "MENINO",
                                perfilLogico: "crianca",
                                imagem: "assets/images/menino.png",
                                neonColor: Color(0xFFFFD700),
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "MENINA",
                                perfilLogico: "crianca",
                                imagem: "assets/images/menina.png",
                                neonColor: Color(0xFFC040FF),
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "ADULTO",
                                perfilLogico: "adulto",
                                imagem: "assets/images/adulto.png",
                                neonColor: AppColors.neonCiano,
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "PROFESSOR",
                                perfilLogico: "professor",
                                imagem: "assets/images/professor.png",
                                neonColor: AppColors.neonVerde,
                              ),
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

          // 3. BOTÃO DE SAIR REATIVO (Colocado por último para garantir o clique no topo)
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 32),
                tooltip: "Sair e trocar de conta",
                onPressed: () async {
                  try {
                    // Aciona o fluxo limpo do seu controlador que avisa o repositório e limpa a UI
                    await Provider.of<AuthController>(context, listen: false).logout();
                  } catch (e) {
                    debugPrint("Erro ao deslogar pelo controlador: $e");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET INTERNO: CARD ANIMADO ---

class _CardPerfilAnimado extends StatefulWidget {
  final String labelExibicao;
  final String perfilLogico;
  final String imagem;
  final Color neonColor;

  const _CardPerfilAnimado({
    required this.labelExibicao,
    required this.perfilLogico,
    required this.imagem,
    required this.neonColor,
  });

  @override
  State<_CardPerfilAnimado> createState() => _CardPerfilAnimadoState();
}

class _CardPerfilAnimadoState extends State<_CardPerfilAnimado> {
  double _escala = 1.0;
  bool _isHovered = false;

  void _selecionarPerfil() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.neonCiano),
      ),
    );

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      await authController.realizarLogin(
        nome: widget.labelExibicao,
        perfil: widget.perfilLogico,
        tipo: widget.perfilLogico,
        onSuccess: () {
          if (mounted) Navigator.pop(context);
        },
        onError: (erro) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() {
        _escala = 1.05;
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _escala = 1.0;
        _isHovered = false;
      }),
      child: GestureDetector(
        onTap: _selecionarPerfil,
        child: AnimatedScale(
          scale: _escala,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isHovered ? widget.neonColor : widget.neonColor.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 20 : 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagem,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white24),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Text(
                      widget.labelExibicao,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
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