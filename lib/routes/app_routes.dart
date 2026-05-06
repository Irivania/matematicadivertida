import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/nivel_screen.dart';
import '../screens/jogo_screen.dart';

class AppRoutes {
  static const home = "/";
  static const perfil = "/perfil";
  static const nivel = "/nivel";
  static const jogo = "/jogo";

  static final routes = {
    home: (_) => const HomeScreen(),
    perfil: (_) => const PerfilScreen(),
    nivel: (_) => const NivelScreen(),
    jogo: (_) => const JogoScreen(),
  };
}