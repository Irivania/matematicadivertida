import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escolha o Perfil")),
      body: Column(
        children: [
          _btn(context, "Criança"),
          _btn(context, "Adulto"),
          _btn(context, "Professor"),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String perfil) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.nivel,
            arguments: perfil);
      },
      child: Text(perfil),
    );
  }
}