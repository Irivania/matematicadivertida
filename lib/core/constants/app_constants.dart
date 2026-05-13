/// Classe central de constantes do sistema.
/// Segue o princípio de Single Source of Truth (Fonte Única de Verdade).
class AppConstants {
  AppConstants._(); // Impede a instanciação da classe

  // --- Identificadores de Coleções Firestore ---
  static const String colUsuarios = 'usuarios';
  static const String colPartidas = 'partidas';
  static const String colPerguntas = 'perguntas';

  // --- Configurações de Jogo ---
  static const int tempoPadraoResposta = 30; // em segundos
  static const int pontosPorAcerto = 10;
  static const int vidasIniciais = 3;

  // --- Mensagens de Erro Padrão (UX) ---
  static const String erroGenerico = 'Ocorreu um erro inesperado. Tente novamente.';
  static const String erroAuth = 'Falha na autenticação. Verifique sua conexão.';
  static const String erroSemInternet = 'Você parece estar sem conexão com a internet.';

  // --- Assets Paths (Prevenir erros de digitação em caminhos de imagem) ---
  static const String logoPath = 'assets/images/logo.png';
  static const String avatarPadrao = 'assets/images/default_avatar.png';
  static const String somAcerto = 'sounds/success.mp3';
}