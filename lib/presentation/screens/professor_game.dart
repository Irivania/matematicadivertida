import 'package:flutter/material.dart';

class ProfessorGame extends StatelessWidget {
  const ProfessorGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Painel do Professor 📊")),
      body: const Center(
        child: Text("Aqui o professor gerencia as questões e vê o progresso da turma."),
      ),
    );
  }
}