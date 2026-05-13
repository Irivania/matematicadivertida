import 'package:intl/intl.dart';

class Helpers {
  Helpers._(); // Privado para evitar instanciação

  /// Formata data para o padrão brasileiro (Ex: 12/05/2026)
  static String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  /// Valida se um e-mail é estruturalmente correto
  static bool isEmailValido(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  /// Gera um feedback textual baseado no desempenho do aluno
  /// Útil para as telas de fim de jogo ou progresso
  static String obterMensagemMotivacional(int acertos, int total) {
    double aproveitamento = acertos / total;
    
    if (aproveitamento == 1.0) return "Incrível! Você é um mestre da matemática!";
    if (aproveitamento >= 0.7) return "Muito bem! Continue praticando para a perfeição.";
    if (aproveitamento >= 0.5) return "Bom trabalho! Você está no caminho certo.";
    return "Não desista! Cada erro é uma oportunidade de aprender.";
  }

  /// Remove caracteres especiais e espaços extras de uma string
  /// Útil para processar inputs de respostas de texto do usuário
  static String normalizarTexto(String texto) {
    return texto.trim().toLowerCase();
  }

  /// Converte segundos em formato de MM:SS para o timer do jogo
  static String formatarTimer(int segundos) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final segs = (segundos % 60).toString().padLeft(2, '0');
    return '$minutos:$segs';
  }
}