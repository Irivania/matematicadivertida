import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NivelScreen extends StatelessWidget {
  const NivelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Nível - $perfil")),
      body: Column(
        children: [
          _btn(context, "Bronze", perfil),
          _btn(context, "Prata", perfil),
          _btn(context, "Ouro", perfil),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String nivel, dynamic perfil) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.jogo,
          arguments: {
            "perfil": perfil,
            "nivel": nivel,
          },
        );
      },
      child: Text(nivel),
    );
  }
}