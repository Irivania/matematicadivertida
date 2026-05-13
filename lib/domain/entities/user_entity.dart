import 'package:meta/meta.dart';

/// Define as categorias biológicas/pedagógicas de forma tipada.
enum TipoUsuario { adulto, crianca }

/// Define o papel administrativo/funcional no sistema.
enum PerfilUsuario { professor, aluno, visitante }

@immutable
class UserEntity {
  final String uid;
  final String email;
  
  /// Nome de exibição (Sincronizado com Firebase Auth e Repository)
  final String? displayName; 
  
  final String? fotoUrl;
  final PerfilUsuario perfil;
  final TipoUsuario tipo;
  final int pontuacaoTotal;
  final int nivelAtual;
  final DateTime? ultimaEntrada;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.fotoUrl,
    this.perfil = PerfilUsuario.aluno,
    this.tipo = TipoUsuario.crianca,
    this.pontuacaoTotal = 0,
    this.nivelAtual = 1,
    this.ultimaEntrada,
  });

  // ---------------------------------------------------
  // GETTERS DE LÓGICA DE NEGÓCIO
  // ---------------------------------------------------

  /// Retorna um nome amigável.
  /// Prioriza o displayName; se nulo, extrai a parte antes do '@' no email.
  String get nomeExibicao => 
      displayName ?? (email.isNotEmpty ? email.split('@').first : 'Usuário');

  /// Verifica se o usuário possui privilégios de professor/administrador.
  bool get isAdmin => perfil == PerfilUsuario.professor;

  // ---------------------------------------------------
  // MÉTODOS DE EVOLUÇÃO E IMUTABILIDADE
  // ---------------------------------------------------

  /// Cria uma nova instância com dados atualizados.
  /// Essencial para o gerenciamento de estado reativo.
  UserEntity copyWith({
    String? displayName,
    String? fotoUrl,
    PerfilUsuario? perfil,
    TipoUsuario? tipo,
    int? pontuacaoTotal,
    int? nivelAtual,
    DateTime? ultimaEntrada,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      perfil: perfil ?? this.perfil,
      tipo: tipo ?? this.tipo,
      pontuacaoTotal: pontuacaoTotal ?? this.pontuacaoTotal,
      nivelAtual: nivelAtual ?? this.nivelAtual,
      ultimaEntrada: ultimaEntrada ?? this.ultimaEntrada,
    );
  }

  /// Calcula a evolução do jogador: sobe de nível a cada 1000 pontos.
  UserEntity adicionarPontos(int pontos) {
    final novaPontuacao = pontuacaoTotal + pontos;
    final novoNivel = (novaPontuacao / 1000).floor() + 1;

    return copyWith(
      pontuacaoTotal: novaPontuacao,
      nivelAtual: novoNivel,
    );
  }

  // ---------------------------------------------------
  // OVERRIDES (IGUALDADE E DEBUG)
  // ---------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && 
      runtimeType == other.runtimeType && 
      uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserEntity(uid: $uid, email: $email, name: $displayName, level: $nivelAtual)';
  }
}