import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../core/enums/nivel_enum.dart';
import '../core/enums/nivel_ext.dart';

class NivelScreen extends StatelessWidget {
  const NivelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Nível - $perfil")),
      body: Column(
        children: [
          for (final nivel in Nivel.values)
            _btn(context, nivel, perfil),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, Nivel nivel, dynamic perfil) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.jogo,
          arguments: {
            "perfil": perfil,
            "nivel": nivel.name, // ou nivel se espera o enum
          },
        );
      },
      child: Text(nivel.nome),
    );
  }
}