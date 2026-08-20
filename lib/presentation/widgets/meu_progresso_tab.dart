// lib/presentation/widgets/meu_progresso_tab.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/enums/nivel_enum.dart';
import '../../data/models/game_state.dart';

class MeuProgressoTab extends StatelessWidget {
  final GameState gameState;
  const MeuProgressoTab({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final bool eIngles = gameState.currentLocale.languageCode == 'en';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              children: [
                Text(
                  eIngles 
                    ? "Active Profile: ${gameState.perfil.toUpperCase()}" 
                    : "Perfil Ativo: ${gameState.perfil.toUpperCase()}", 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(color: AppColors.neonCiano, fontSize: 14, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 12),
                
                // Gráfico de Evolução
                _buildGraficoEvolucaoTempo(eIngles),
                const SizedBox(height: 16),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    eIngles ? "Medals by Level" : "Medalhas por Nível", 
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: 8),
                
                // Lista de cards de progresso
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: Nivel.values.length,
                  itemBuilder: (context, index) {
                    final nivel = Nivel.values[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildCardProgressoNivel(
                        nivel, 
                        gameState.obterTipoMedalha(nivel.name), 
                        gameState.obterTempoTotalNivel(nivel.name),
                        eIngles,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficoEvolucaoTempo(bool eIngles) {
    List<FlSpot> pontos = [];
    double maiorTempo = 10.0;
    for (int i = 1; i <= 10; i++) {
      int tempo = gameState.obterTempoDaFase(i);
      if (tempo > maiorTempo) maiorTempo = tempo.toDouble();
      pontos.add(FlSpot(i.toDouble(), tempo.toDouble()));
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eIngles ? "📈 Performance Curve (Time per Phase)" : "📈 Curva de Desempenho (Tempo por Fase)", 
            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0, 
                maxY: maiorTempo + 20,
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.black12, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('${v.toInt()}ª', style: const TextStyle(color: Colors.black54, fontSize: 9)))),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) => Text('${v.toInt()}s', style: const TextStyle(color: Colors.black54, fontSize: 9)))),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: pontos, 
                    isCurved: true, 
                    color: Colors.blueAccent, 
                    barWidth: 2.5, 
                    dotData: const FlDotData(show: true), 
                    belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.15))
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cores atrativas exclusivas para cada nível
  Color _obterCorDoNivel(Nivel nivel) {
    switch (nivel) {
      case Nivel.bronze:
        return const Color(0xFFD77A33); // Tom de Cobre/Bronze vibrante
      case Nivel.prata:
        return const Color(0xFF78909C); // Cinza Prateado metálico
      case Nivel.ouro:
        return const Color(0xFFD4AF37); // Amarelo Ouro brilhante
      case Nivel.platina:
        return const Color(0xFF00ACC1); // Azul Ciano Platina
      case Nivel.mestre:
        return const Color(0xFF8E24AA); // Roxo Mestre forte
    }
  }

  Widget _buildCardProgressoNivel(Nivel nivel, String medalha, int tempoSegundos, bool eIngles) {
    bool conquistada = medalha.isNotEmpty;
    final Color corNivel = _obterCorDoNivel(nivel);

    String textoTempo = eIngles ? "⏱️ Total Time: --" : "⏱️ Tempo Total: --";
    if (tempoSegundos > 0) {
      int min = tempoSegundos ~/ 60;
      int seg = tempoSegundos % 60;
      textoTempo = min > 0 
          ? (eIngles ? "⏱️ Total Time: $min min ${seg > 0 ? '$seg s' : ''}" : "⏱️ Tempo Total: $min min ${seg > 0 ? '$seg s' : ''}")
          : (eIngles ? "⏱️ Total Time: $seg s" : "⏱️ Tempo Total: $seg s");
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: corNivel.withOpacity(0.2), 
            blurRadius: 6, 
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: corNivel, width: conquistada ? 2.2 : 1.5),
      ),
      child: Row(
        children: [
          // Ícone estilizado com fundo e cor temática do nível
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corNivel.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(nivel.icone, color: corNivel, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nivel.name.toUpperCase(), 
                  style: TextStyle(color: corNivel, fontSize: 14, fontWeight: FontWeight.w900)
                ),
                const SizedBox(height: 2),
                Text(
                  conquistada 
                      ? (eIngles ? "Achievement: $medalha" : "Conquista: $medalha") 
                      : (eIngles ? "Status: Not Completed" : "Status: Não Concluído"), 
                  style: TextStyle(color: conquistada ? Colors.green.shade700 : Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 1),
                Text(
                  textoTempo, 
                  style: const TextStyle(color: Colors.black87, fontSize: 10)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}