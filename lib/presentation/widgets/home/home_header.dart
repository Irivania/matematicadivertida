// lib/presentation/widgets/home/home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final TextEditingController _nomeController = TextEditingController();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    String nomeSalvo = authController.usuarioAtual?.nomeExibicao ?? authController.nomeJogador;

    if (_isEditing) {
      return _buildEditMode(authController, nomeSalvo);
    }

    return _buildViewMode(nomeSalvo);
  }

  Widget _buildViewMode(String nome) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 99),
          child: Text(
            "OLÁ, ${nome.toUpperCase()}!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _nomeController.text = nome;
            setState(() => _isEditing = true);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Editar apelido",
              style: TextStyle(
                color: AppColors.neonCiano,
                fontSize: 11,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode(AuthController authController, String nomeAtual) {
    return Column(
      children: [
        const Icon(Icons.account_circle, size: 44, color: AppColors.neonCiano),
        const SizedBox(height: 8),
        const Text("BEM-VINDO(A)! 👋\nCOMO QUER SER CHAMADO(A)?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Digite seu apelido...",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.neonCiano),
              onPressed: () async {
                final nomeDigitado = _nomeController.text.trim();
                if (nomeDigitado.isNotEmpty) {
                  await authController.escolherPerfilParaJogar(
                    nome: nomeDigitado,
                    perfilEscolhido: "crianca",
                  );
                  setState(() => _isEditing = false);
                }
              },
              icon: const Icon(Icons.check, color: AppColors.backgroundEscuro),
            ),
          ],
        ),
      ],
    );
  }
}