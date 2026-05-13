import 'package:flutter/material.dart';
// Importações Corrigidas com Caminhos Absolutos
import 'package:matematicadivertida/core/theme/app_colors.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final alturaTela = MediaQuery.of(context).size.height;
    final AuthService authService = AuthService();

    // Lógica de colunas responsiva
    int colunas = 4;
    if (largura < 1200) colunas = 2;
    if (largura < 700) colunas = 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // 1. Fundo da tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_imagem_perfil.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              // Fallback caso a imagem falte para não travar o app
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.backgroundEscuro),
            ),
          ),
          
          // 2. BOTÃO DE SAIR (LOGOUT)
          Positioned(
            top: 20,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 32),
                tooltip: "Sair e trocar de conta",
                onPressed: () async {
                  await authService.sair();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
            ),
          ),

          // 3. Conteúdo Principal
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
                            children: [
                              _CardPerfilAnimado(
                                labelExibicao: "MENINO",
                                perfilLogico: "crianca", 
                                imagem: "assets/images/menino.png", 
                                neonColor: const Color(0xFFFFD700),
                              ),
                              _CardPerfilAnimado(
                                labelExibicao: "MENINA",
                                perfilLogico: "crianca", 
                                imagem: "assets/images/menina.png", 
                                neonColor: const Color(0xFFC040FF),
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
  bool _isHovered = false;
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
      // Atualiza no Firebase o tipo de perfil escolhido
      await _authService.atualizarPerfilUsuario(widget.perfilLogico);
      
      if (mounted) {
        Navigator.pop(context); // Fecha o loading
        // Navega para a tela de Níveis passando o perfil escolhido como argumento
        Navigator.pushNamed(
          context, 
          AppRoutes.nivel, 
          arguments: widget.perfilLogico,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar perfil. Tente novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() { _escala = 1.05; _isHovered = true; }),
      onExit: (_) => setState(() { _escala = 1.0; _isHovered = false; }),
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
                color: _isHovered ? widget.neonColor : widget.neonColor.withValues(alpha: 0.5), 
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withValues(alpha: _isHovered ? 0.4 : 0.2),
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
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.white24),
                  ),
                  
                  // Gradiente para leitura do texto
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
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