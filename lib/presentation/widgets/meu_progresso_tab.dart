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
      padding: const EdgeInsets.all(24),
      children: [
        Text("Perfil Ativo: ${gameState.perfil.toUpperCase()}", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.neonCiano, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGraficoEvolucaoTempo(),
        const SizedBox(height: 24),
        const Text("Medalhas por Nível", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 1, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 12, childAspectRatio: 3.5,
          children: Nivel.values.map((nivel) {
            return _buildCardProgressoNivel(nivel, gameState.obterTipoMedalha(nivel.name), gameState.obterTempoTotalNivel(nivel.name));
          }).toList(),
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
      height: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📈 Curva de Desempenho (Tempo por Fase)", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(child: LineChart(LineChartData(
            minY: 0, maxY: maiorTempo + 20,
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1)),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('${v.toInt()}ª', style: const TextStyle(color: Colors.white60, fontSize: 10)))),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) => Text('${v.toInt()}s', style: const TextStyle(color: Colors.white60, fontSize: 9)))),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(spots: pontos, isCurved: true, color: AppColors.neonCiano, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: AppColors.neonCiano.withOpacity(0.2)))],
          ))),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(15), border: Border.all(color: conquistada ? Colors.amber : Colors.white24, width: conquistada ? 2 : 1)),
      child: Row(
        children: [
          Icon(nivel.icone, color: conquistada ? Colors.amber : Colors.white70, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(nivel.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(conquistada ? "Conquista: $medalha" : "Status: Não Concluído", style: TextStyle(color: conquistada ? AppColors.neonCiano : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(textoTempo, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          )),
        ],
      ),
    );
  }
}