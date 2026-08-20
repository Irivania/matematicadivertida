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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85), // Fundo translúcido elegante
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "OLÁ, ${nome.toUpperCase()}!",
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              _nomeController.text = nome;
              setState(() => _isEditing = true);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.neonCiano.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.black87, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditMode(AuthController authController, String nomeAtual) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCiano, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            "COMO QUER SER CHAMADO(A)?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                    fillColor: Colors.black.withOpacity(0.4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
                icon: const Icon(Icons.check, color: Colors.black, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}