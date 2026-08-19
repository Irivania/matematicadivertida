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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Usamos um Center + ConstrainedBox para limitar a largura e evitar que estique de canto a canto
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              children: [
                Text(
                  "Perfil Ativo: ${gameState.perfil.toUpperCase()}", 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(color: AppColors.neonCiano, fontSize: 14, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 12),
                
                // Gráfico mais compacto
                _buildGraficoEvolucaoTempo(),
                const SizedBox(height: 16),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Medalhas por Nível", 
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: 8),
                
                // Lista de cards de progresso dos níveis mais curtos
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

  Widget _buildGraficoEvolucaoTempo() {
    List<FlSpot> pontos = [];
    double maiorTempo = 10.0;
    for (int i = 1; i <= 10; i++) {
      int tempo = gameState.obterTempoDaFase(i);
      if (tempo > maiorTempo) maiorTempo = tempo.toDouble();
      pontos.add(FlSpot(i.toDouble(), tempo.toDouble()));
    }

    return Container(
      height: 180, // Altura reduzida para ficar mais compacto
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Fundo claro sólido igual aos cards
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📈 Curva de Desempenho (Tempo por Fase)", 
            style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)
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

  Widget _buildCardProgressoNivel(Nivel nivel, String medalha, int tempoSegundos) {
    bool conquistada = medalha.isNotEmpty;
    String textoTempo = "⏱️ Tempo Total: --";
    if (tempoSegundos > 0) {
      int min = tempoSegundos ~/ 60;
      int seg = tempoSegundos % 60;
      textoTempo = min > 0 ? "⏱️ Tempo Total: $min min ${seg > 0 ? '$seg s' : ''}" : "⏱️ Tempo Total: $seg s";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Padding interno reduzido
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Fundo branco sólido
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 3, offset: const Offset(0, 1))],
        border: Border.all(color: conquistada ? Colors.amber.shade700 : Colors.black26, width: conquistada ? 1.8 : 1.0),
      ),
      child: Row(
        children: [
          Icon(nivel.icone, color: conquistada ? Colors.amber.shade700 : Colors.black45, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nivel.name.toUpperCase(), 
                  style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 1),
                Text(
                  conquistada ? "Conquista: $medalha" : "Status: Não Concluído", 
                  style: TextStyle(color: conquistada ? Colors.green.shade700 : Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)
                ),
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