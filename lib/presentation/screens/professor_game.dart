// lib/presentation/screens/professor_game.dart
import 'package:flutter/material.dart';

class ProfessorGame extends StatelessWidget {
  const ProfessorGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo escuro imersivo padrão do app
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "Painel do Professor 📊",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BOAS-VINDAS / RESUMO
              const Text(
                "Visão Geral da Turma",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Acompanhe o progresso e gerencie as atividades pedagógicas.",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // CARDS DE ESTATÍSTICAS RÁPIDAS
              Row(
                children: [
                  Expanded(
                    child: _buildCardMetrica(
                      titulo: "Alunos Ativos",
                      valor: "28",
                      icone: Icons.group,
                      cor: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardMetrica(
                      titulo: "Média de Acertos",
                      valor: "84%",
                      icone: Icons.trending_up,
                      cor: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SEÇÃO DE AÇÕES / GERENCIAMENTO
              const Text(
                "Ferramentas de Gestão",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildBotaoPainel(
                context,
                titulo: "Gerenciar Questões e Fases",
                subtitulo: "Adicionar ou editar perguntas do sistema",
                icone: Icons.quiz,
                onTap: () {
                  // Ação futura de gerenciamento
                },
              ),
              const SizedBox(height: 12),
              _buildBotaoPainel(
                context,
                titulo: "Relatórios de Desempenho",
                subtitulo: "Visualizar estatísticas detalhadas por aluno",
                icone: Icons.bar_chart,
                onTap: () {
                  // Ação futura de relatórios
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMetrica({required String titulo, required String valor, required IconData icone, required Color cor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 28),
          const SizedBox(height: 12),
          Text(valor, style: TextStyle(color: cor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(titulo, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBotaoPainel(BuildContext context, {required String titulo, required String subtitulo, required IconData icone, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}