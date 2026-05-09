import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // =====================================================
      // APPBAR
      // =====================================================

      appBar: AppBar(
        title: const Text("Matemática Divertida"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Stack(
        children: [

          // =================================================
          // FUNDO
          // =================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/fundo_perfil.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay escuro
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          // =================================================
          // CONTEÚDO
          // =================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),

              child: Column(
                children: [

                  const SizedBox(height: 8),

                  const Text(
                    "ESCOLHA O PERFIL",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =========================================
                  // GRID ESTILO NETFLIX
                  // =========================================

                  Expanded(
                    child: GridView.count(

                      // 2 cards por linha
                      crossAxisCount: 2,

                      // 🔥 CARDS MENORES
                      childAspectRatio: 1.15,

                      // 🔥 ESPAÇAMENTO MENOR
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,

                      children: [

                        // =====================================
                        // MENINO
                        // =====================================

                        _cardPerfil(
                          context,
                          nome: "MENINO",
                          perfil: "crianca",
                          imagem: "assets/images/menino.jpeg",
                        ),

                        // =====================================
                        // MENINA
                        // =====================================

                        _cardPerfil(
                          context,
                          nome: "MENINA",
                          perfil: "crianca",
                          imagem: "assets/images/menina.jpeg",
                        ),

                        // =====================================
                        // ADULTO
                        // =====================================

                        _cardPerfil(
                          context,
                          nome: "ADULTO",
                          perfil: "adulto",
                          imagem: "assets/images/adulto1.jpeg",
                        ),

                        // =====================================
                        // PROFESSOR
                        // =====================================

                        _cardPerfil(
                          context,
                          nome: "PROFESSOR",
                          perfil: "professor",
                          imagem: "assets/images/professor1.png",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD PERFIL
  // =========================================================

  Widget _cardPerfil(
    BuildContext context, {
    required String nome,
    required String perfil,
    required String imagem,
  }) {

    return GestureDetector(

      onTap: () {

        Navigator.pushNamed(
          context,
          AppRoutes.jogo,
          arguments: perfil,
        );
      },

      child: Container(

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: Stack(
            children: [

              // =============================================
              // IMAGEM
              // =============================================

              Positioned.fill(
                child: Image.asset(
                  imagem,
                  fit: BoxFit.cover,
                ),
              ),

              // =============================================
              // OVERLAY
              // =============================================

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // =============================================
              // TEXTO
              // =============================================

              Positioned(
                bottom: 8,
                left: 8,
                right: 8,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),

                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),

                  child: Text(
                    nome,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}