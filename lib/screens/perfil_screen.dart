import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final alturaTela = MediaQuery.of(context).size.height;

    // Lógica de responsividade para as colunas
    int colunas = 4;
    if (largura < 1200) colunas = 2;
    if (largura < 700) colunas = 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // Fundo da tela
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
                      const SizedBox(height: 100), // Ajustado para visibilidade melhor
                      const Text(
                        "ESCOLHA O PERFIL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(
                              blurRadius: 15, 
                              color: AppColors.neonCiano, 
                              offset: Offset(0, 0)
                            ),
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
                              _CardPerfilAnimado(
                                perfil: "menino", 
                                imagem: "assets/images/menino.png", 
                                neonColor: const Color(0xFFFFD700)
                              ),
                              _CardPerfilAnimado(
                                perfil: "menina", 
                                imagem: "assets/images/menina.png", 
                                neonColor: const Color(0xFFC040FF)
                              ),
                              _CardPerfilAnimado(
                                perfil: "adulto", 
                                imagem: "assets/images/adulto1.png", 
                                neonColor: AppColors.neonCiano
                              ),
                              _CardPerfilAnimado(
                                perfil: "professor", 
                                imagem: "assets/images/professor1.png", 
                                neonColor: AppColors.neonVerde
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
        ],
      ),
    );
  }
}

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
  double _escala = 1.0;
  final AuthService _authService = AuthService();

  // Função que salva no Firebase e navega
  void _selecionarPerfil() async {
    // Mostra um loading neon enquanto salva no Firestore
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.neonCiano),
      ),
    );

    // Salva a escolha no Firebase vinculada ao ID único do usuário
    await _authService.atualizarPerfilUsuario(widget.perfil);

    if (mounted) {
      Navigator.pop(context); // Fecha o loading
      // Navega para a tela de jogo passando o perfil como argumento
      Navigator.pushNamed(
        context, 
        AppRoutes.jogo, 
        arguments: widget.perfil
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _escala = 1.05),
      onExit: (_) => setState(() => _escala = 1.0),
      child: GestureDetector(
        onTap: _selecionarPerfil,
        child: AnimatedScale(
          scale: _escala,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: widget.neonColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.4),
                  blurRadius: _escala > 1.0 ? 25 : 15,
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
                    child: Image.asset(
                      widget.imagem, 
                      fit: BoxFit.cover, 
                      alignment: Alignment.topCenter
                    ),
                  ),
                  // Gradiente Neon interno para dar profundidade
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