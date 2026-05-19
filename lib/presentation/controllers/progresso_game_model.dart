/// Representa o progresso de um perfil específico (Criança, Adulto ou Professor)
class ProgressoPerfil {
  final int fase;
  final int nivel;

  ProgressoPerfil({
    required this.fase,
    required this.nivel,
  });

  // Converte o mapa (JSON) vindo do banco para o objeto do Flutter
  factory ProgressoPerfil.fromMap(Map<String, dynamic> map) {
    return ProgressoPerfil(
      fase: map['fase'] ?? 1,
      nivel: map['nivel'] ?? 1,
    );
  }

  // Converte o objeto do Flutter para mapa (JSON) para ser salvo no banco
  Map<String, dynamic> toMap() {
    return {
      'fase': fase,
      'nivel': nivel,
    };
  }
}

/// Representa a estrutura global do Jogador com seus 3 modos de jogo independentes
class ProgressoGameModel {
  final String nomeJogador;
  final ProgressoPerfil crianca;
  final ProgressoPerfil adulto;
  final ProgressoPerfil professor;

  ProgressoGameModel({
    required this.nomeJogador,
    required this.crianca,
    required this.adulto,
    required this.professor,
  });

  // Converte a estrutura completa vinda do banco para o modelo local
  factory ProgressoGameModel.fromMap(Map<String, dynamic> map) {
    return ProgressoGameModel(
      nomeJogador: map['nomeJogador'] ?? '',
      crianca: ProgressoPerfil.fromMap(map['progresso_crianca'] ?? {}),
      adulto: ProgressoPerfil.fromMap(map['progresso_adulto'] ?? {}),
      professor: ProgressoPerfil.fromMap(map['progresso_professor'] ?? {}),
    );
  }

  // Converte toda a estrutura para o formato JSON que o banco de dados exige
  Map<String, dynamic> toMap() {
    return {
      'nomeJogador': nomeJogador,
      'progresso_crianca': crianca.toMap(),
      'progresso_adulto': adulto.toMap(),
      'progresso_professor': professor.toMap(),
    };
  }
}