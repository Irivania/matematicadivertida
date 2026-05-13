class UserEntity {
  final String uid;
  final String email;
  final String? nome;
  final String? fotoUrl;
  final String? perfil; // 'professor', 'aluno', etc.
  final String? tipo;   // 'adulto', 'crianca'
  final int pontuacaoTotal;

  UserEntity({
    required this.uid,
    required this.email,
    this.nome,
    this.fotoUrl,
    this.perfil,
    this.tipo,
    this.pontuacaoTotal = 0,
  });
}