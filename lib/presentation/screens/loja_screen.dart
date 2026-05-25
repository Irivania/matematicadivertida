// lib/presentation/screens/loja_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Para o efeito de vidro (blur)
import '../../data/models/game_state.dart';

class LojaScreen extends StatelessWidget {
  const LojaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return Scaffold(
      body: Stack(
        children: [
          // Fundo configurado com a sua imagem
          Positioned.fill(
            child: Image.asset(
              'assets/images/loja_do_cal.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Camada de sobreposição para garantir leitura do texto
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("Loja do Cal 🤖", 
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Painel de Saldo com efeito Glassmorphism
                  _buildGlassContainer(
                    child: ListTile(
                      leading: const Icon(Icons.star, color: Colors.amber, size: 40),
                      title: const Text("Seu XP Atual", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      trailing: Text("${gs.xpTotal}", style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Item Vida Extra
                  _buildGlassContainer(
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title: const Text("Vida Extra", style: TextStyle(color: Colors.white)),
                      subtitle: const Text("Recupere uma tentativa perdida", style: TextStyle(color: Colors.white70)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        onPressed: () {
                          bool sucesso = gs.comprarVidaExtra();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(sucesso ? "Vida comprada com sucesso! ❤️" : "XP insuficiente! ❌")),
                          );
                        },
                        child: const Text("500 XP", style: TextStyle(color: Colors.black)),
                      ),
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

  // Método auxiliar para o efeito visual de vidro
  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: child,
        ),
      ),
    );
  }
}