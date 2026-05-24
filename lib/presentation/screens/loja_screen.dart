// lib/presentation/screens/loja_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class LojaScreen extends StatelessWidget {
  const LojaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos watch para que a tela atualize o XP automaticamente após a compra
    final gs = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loja do Cal 🤖"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Painel de Saldo
            Card(
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.amber, size: 40),
                title: const Text("Seu XP Atual", style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text("${gs.xpTotal}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            
            // Item: Vida Extra
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text("Vida Extra"),
                subtitle: const Text("Recupere uma tentativa perdida"),
                trailing: ElevatedButton(
                  onPressed: () {
                    bool sucesso = gs.comprarVidaExtra();
                    if (sucesso) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vida comprada com sucesso! ❤️")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("XP insuficiente! ❌")),
                      );
                    }
                  },
                  child: const Text("500 XP"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}