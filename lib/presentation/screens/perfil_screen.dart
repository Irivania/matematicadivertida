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
          // 1. FUNDO DA TELA DE PERFIL (Apontando para a nova arte integrada)
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.backgroundEscuro),
            ),
          ),

          // Máscara ultra suave para dar uma leve leitura aos textos sem esconder a arte
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

          // 2. CONTEÚDO PRINCIPAL
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
                      // 🚨 AJUSTE: Aumentado o recuo para 40% da tela para o título e a seleção 
                      // começarem abaixo da área principal do desenho (rostos dos personagens)
                      SizedBox(height: alturaTela * 0.40),
                      
                      const Text(
                        "ESCOLHA SEU AVATAR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(blurRadius: 15, color: AppColors.neonCiano),
                            Shadow(blurRadius: 10, color: Colors.black54),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // GRID DE SELEÇÃO COM AS SUAS IMAGENS CORRETAS
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: colunas,
                            childAspectRatio: 0.85, // Ajustado levemente para encaixar melhor os avatares
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 25,
                            children: const [
                              _CardPerfilAnimado(
                                labelExibicao: "MENINO",
                                perfilLogico: "crianca",
                                imagem: "assets/images/menino.png",
                                neonColor: AppColors.neonCiano,
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
                                imagem: "assets/images/perfil_adulto.png",
                                neonColor: Color(0xFFFFD700),
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "PROFESSOR",
                                perfilLogico: "professor",
                                imagem: "assets/images/perfil_professor.png",
                                neonColor: AppColors.neonVerde,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTÃO DE SAIR REATIVO (No topo)
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 28),
                  tooltip: "Sair e trocar de conta",
                  onPressed: () async {
                    try {
                      await Provider.of<AuthController>(context, listen: false).logout();
                    } catch (e) {
                      debugPrint("Erro ao deslogar pelo controlador: $e");
                    }
                  },
                ),
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
          if (mounted) {
            Navigator.pop(context); // Fecha o loading dialog
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        onError: (erro) {
          if (mounted) {
            Navigator.pop(context); // Fecha o loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(erro),
                backgroundColor: Colors.redAccent,
              ),
            );
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
              color: Colors.white.withOpacity(0.05), // Fundo translúcido para o card
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isHovered ? widget.neonColor : widget.neonColor.withOpacity(0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(_isHovered ? 0.35 : 0.15),
                  blurRadius: _isHovered ? 18 : 8,
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
                      color: Colors.white24,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                          stops: const [0.65, 1.0],
                        ),
                      ),
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
                        fontSize: 15,
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