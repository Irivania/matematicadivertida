// lib/presentation/screens/loja_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class LojaScreen extends StatelessWidget {
  const LojaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. FUNDO COM ALINHAMENTO CENTRALIZADO PARA ENQUADRAMENTO PERFEITO NO CELULAR
          Positioned.fill(
            child: Image.asset(
              'assets/images/loja_do_cal.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. CONTEÚDO RESPONSIVO
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
                      child: Column(
                        children: [
                          // CABEÇALHO COM SACOLA AMARELA
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.shopping_bag, color: Colors.amber, size: 35),
                                const SizedBox(width: 10),
                                const Text("Loja do Cal",
                                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          const Spacer(), 

                          // CARDS COM MAIS ALTURA (MAIS GROSSOS)
                          Center(
                            child: SizedBox(
                              width: 500,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    // Card XP
                                    Card(
                                      color: Colors.green.shade600,
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: ListTile(
                                          leading: const Icon(Icons.star, color: Colors.white, size: 45),
                                          title: const Text("Seu XP Atual", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                          trailing: Text("${gs.xpTotal}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    // Card Vida Extra
                                    Card(
                                      color: Colors.blue.shade600,
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: ListTile(
                                          leading: const Icon(Icons.favorite, color: Colors.white, size: 40),
                                          title: const Text("Vida Extra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                          subtitle: const Text("Recupere 1 tentativa", style: TextStyle(color: Colors.white70)),
                                          trailing: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                            ),
                                            onPressed: () {
                                              bool sucesso = gs.comprarVidaExtra();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(sucesso ? "Vida comprada! ❤️" : "XP insuficiente! ❌")),
                                              );
                                            },
                                            child: const Text("500 XP", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const Spacer(flex: 2), 
                        ],
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