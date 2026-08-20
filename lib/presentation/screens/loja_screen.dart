// lib/presentation/screens/loja_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class LojaScreen extends StatelessWidget {
  const LojaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eTelaLarga = larguraTela > 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FUNDO UNIFICADO
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5A2A82),
                    Color(0xFF3B1D59),
                    Color(0xFF221133),
                  ],
                ),
              ),
            ),
          ),

          // 2. CONTEÚDO
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: eTelaLarga ? 600 : 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Cabeçalho
                      Row(
                        children: [
                          _buildBackButton(context),
                          const SizedBox(width: 12),
                          const Icon(Icons.shopping_bag_rounded, color: Colors.amber, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            eIngles ? "Cal's Shop" : "Loja do Cal", 
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Image.asset('assets/images/logo_matematica.png', height: eTelaLarga ? 200 : 160, fit: BoxFit.contain),
                      const SizedBox(height: 12),

                      // Lista de Itens
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Saldo de XP
                              _buildItemCard(
                                icon: Icons.star,
                                iconColor: Colors.green.shade700,
                                bgColor: Colors.green.shade100,
                                title: eIngles ? "Your Current XP" : "Seu XP Atual",
                                trailing: "${gs.xpTotal}",
                                isStat: true,
                              ),
                              const SizedBox(height: 16),

                              // Vida Extra
                              _buildItemCard(
                                icon: Icons.favorite,
                                iconColor: Colors.blue.shade700,
                                bgColor: Colors.blue.shade100,
                                title: eIngles ? "Extra Life" : "Vida Extra",
                                subtitle: eIngles ? "Recover 1 attempt" : "Recupere 1 tentativa",
                                actionText: "500 XP",
                                onAction: () {
                                  bool sucesso = gs.comprarVidaExtra();
                                  _mostrarMensagem(
                                    context, 
                                    eIngles 
                                      ? (sucesso ? "Life purchased! ❤️" : "Insufficient XP! ❌") 
                                      : (sucesso ? "Vida comprada! ❤️" : "XP insuficiente! ❌"), 
                                    sucesso
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Óculos Escuros 🕶️
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'oculos',
                                titulo: eIngles ? "Cal Sunglasses 🕶️" : "Cal Óculos Escuros 🕶️",
                                subtitulo: eIngles ? "Guaranteed style for the mascot" : "Estilo garantido para o mascote",
                                custo: 800,
                                icon: Icons.visibility,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Acadêmico 🎓
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'formatura',
                                titulo: eIngles ? "Cal Academic 🎓" : "Cal Acadêmico 🎓",
                                subtitulo: eIngles ? "Exclusive graduation hat" : "Chapéu de formatura exclusivo",
                                custo: 1500,
                                icon: Icons.school,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Detetive 🔍
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'detetive',
                                titulo: eIngles ? "Cal Detective 🔍" : "Cal Detetive 🔍",
                                subtitulo: eIngles ? "Difficult problem investigator" : "Investigador de problemas difíceis",
                                custo: 1000,
                                icon: Icons.search,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Mágico 🧙‍♂️
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'magico',
                                titulo: eIngles ? "Cal Wizard 🧙‍♂️" : "Cal Mágico 🧙‍♂️",
                                subtitulo: eIngles ? "Mathmagic expert" : "Especialista em matemágica",
                                custo: 2000,
                                icon: Icons.auto_fix_high,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Astronauta 🚀
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'astronauta',
                                titulo: eIngles ? "Cal Astronaut 🚀" : "Cal Astronauta 🚀",
                                subtitulo: eIngles ? "Number galaxy explorer" : "Explorador das galáxias numéricas",
                                custo: 2500,
                                icon: Icons.rocket_launch,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 16),

                              // ITEM: Cal Rei da Matemática 👑
                              _buildCosmeticCard(
                                gs: gs,
                                idTraje: 'rei',
                                titulo: eIngles ? "Cal Math King 👑" : "Cal Rei da Matemática 👑",
                                subtitulo: eIngles ? "Exclusive crown for masters" : "Coroa exclusiva para os mestres",
                                custo: 5000,
                                icon: Icons.workspace_premium,
                                context: context,
                                eIngles: eIngles,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildBackButton(BuildContext context) => InkWell(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white30)),
      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
    ),
  );

  Widget _buildItemCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    String? subtitle,
    String? actionText,
    String? trailing,
    bool isStat = false,
    VoidCallback? onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          isStat 
            ? Text(trailing!, style: TextStyle(color: iconColor, fontSize: 24, fontWeight: FontWeight.bold))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: iconColor.withOpacity(0.9), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: onAction,
                child: Text(actionText!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
        ],
      ),
    );
  }

  Widget _buildCosmeticCard({
    required GameState gs,
    required String idTraje,
    required String titulo,
    required String subtitulo,
    required int custo,
    required IconData icon,
    required BuildContext context,
    required bool eIngles,
  }) {
    bool comprado = gs.trajesDesbloqueados.contains(idTraje);
    bool equipado = gs.trajeAtual == idTraje;

    Color corBase = Colors.deepPurple.shade700;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: equipado ? Colors.amber.shade700 : Colors.white.withOpacity(0.8), width: equipado ? 2 : 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), 
            decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(12)), 
            child: Icon(icon, color: corBase, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: equipado 
                  ? Colors.green.shade700 
                  : (comprado ? Colors.amber.shade800 : corBase),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () async {
              bool sucesso = await gs.comprarTraje(idTraje, custo);
              if (equipado) {
                _mostrarMensagem(context, eIngles ? "This item is already equipped! ✨" : "Este item já está equipado! ✨", true);
              } else if (comprado) {
                _mostrarMensagem(context, eIngles ? "Outfit equipped successfully! 🎩" : "Traje equipado com sucesso! 🎩", true);
              } else {
                _mostrarMensagem(
                  context, 
                  eIngles 
                    ? (sucesso ? "Outfit purchased and equipped! 🎉" : "Insufficient XP! ❌") 
                    : (sucesso ? "Traje adquirido e equipado! 🎉" : "XP insuficiente! ❌"), 
                  sucesso
                );
              }
            },
            child: Text(
              equipado 
                ? (eIngles ? "EQUIPPED" : "EQUIPADO") 
                : (comprado ? (eIngles ? "EQUIP" : "EQUIPAR") : "$custo XP"),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(BuildContext context, String texto, bool sucesso) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: sucesso ? Colors.green.shade700 : Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}