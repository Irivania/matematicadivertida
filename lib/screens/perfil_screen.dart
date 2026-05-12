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

    // Lógica de colunas
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
                      // AJUSTE: Aumentado para 360 para baixar mais 15% na tela
                      const SizedBox(height: 360), 

                      const Text(
                        "ESCOLHA O PERFIL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          shadows: [
                            Shadow(
                              blurRadius: 15, 
                              color: AppColors.neonCiano, 
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      
                      Center(
                        child: ConstrainedBox(
                          // AJUSTE: Diminuído para 880 para os cards ficarem menores e "normais"
                          constraints: const BoxConstraints(maxWidth: 880), 
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: colunas,
                            // Mantido em 0.65 para formato de "carta" sem cortes
                            childAspectRatio: 0.65, 
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            children: [
                              _CardPerfilAnimado(
                                labelExibicao: "MENINO",
                                perfilLogico: "crianca", 
                                imagem: "assets/images/menino.png", 
                                neonColor: const Color(0xFFFFD700)
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "MENINA",
                                perfilLogico: "crianca", 
                                imagem: "assets/images/menina.png", 
                                neonColor: const Color(0xFFC040FF)
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "ADULTO",
                                perfilLogico: "adulto", 
                                imagem: "assets/images/adulto1.png", 
                                neonColor: AppColors.neonCiano
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "PROFESSOR",
                                perfilLogico: "professor", 
                                imagem: "assets/images/professor1.png", 
                                neonColor: AppColors.neonVerde
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Espaço extra para garantir que o scroll funcione se a tela for pequena
                      const SizedBox(height: 100), 
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
  final AuthService _authService = AuthService();

  void _selecionarPerfil() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.neonCiano),
      ),
    );

    try {
      await _authService.atualizarPerfilUsuario(widget.perfilLogico);
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pushNamed(context, AppRoutes.jogo, arguments: widget.perfilLogico);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
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
              borderRadius: BorderRadius.circular(18), 
              border: Border.all(color: widget.neonColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.35),
                  blurRadius: _escala > 1.0 ? 18 : 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagem, 
                    fit: BoxFit.cover, 
                    alignment: Alignment.topCenter
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