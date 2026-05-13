// lib/domain/entities/user_entity.dart

import 'package:meta/meta.dart';

/// Define as categorias biológicas/pedagógicas de forma tipada.
enum TipoUsuario { adulto, crianca }

/// Define o papel administrativo/funcional no sistema.
enum PerfilUsuario { professor, aluno, visitante }

@immutable
class UserEntity {
  final String uid;
  final String email;
  final String? nome;
  final String? fotoUrl;
  final PerfilUsuario perfil;
  final TipoUsuario tipo;
  final int pontuacaoTotal;
  final int nivelAtual;
  final DateTime? ultimaEntrada;

  const UserEntity({
    required this.uid,
    required this.email,
    this.nome,
    this.fotoUrl,
    this.perfil = PerfilUsuario.aluno,
    this.tipo = TipoUsuario.crianca,
    this.pontuacaoTotal = 0,
    this.nivelAtual = 1,
    this.ultimaEntrada,
  });

  /// Getter para nome amigável (Fallbacks de UI no Domínio)
  String get nomeExibicao => nome ?? (email.split('@').first);

  /// Lógica de Negócio: Verifica se o usuário pode acessar conteúdos restritos
  bool get isAdmin => perfil == PerfilUsuario.professor;

  /// Cria uma nova instância com dados atualizados (Imutabilidade)
  UserEntity copyWith({
    String? nome,
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
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      perfil: perfil ?? this.perfil,
      tipo: tipo ?? this.tipo,
      pontuacaoTotal: pontuacaoTotal ?? this.pontuacaoTotal,
      nivelAtual: nivelAtual ?? this.nivelAtual,
      ultimaEntrada: ultimaEntrada ?? this.ultimaEntrada,
    );
  }

  /// Lógica de Evolução: Adiciona pontos e calcula se deve subir de nível
  UserEntity adicionarPontos(int pontos) {
    final novaPontuacao = pontuacaoTotal + pontos;
    // Exemplo de regra: sobe de nível a cada 1000 pontos
    final novoNivel = (novaPontuacao / 1000).floor() + 1;

    return copyWith(
      pontuacaoTotal: novaPontuacao,
      nivelAtual: novoNivel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}