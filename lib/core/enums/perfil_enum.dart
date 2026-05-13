enum Perfil {
  crianca,
  adulto,
  professor,
}

extension PerfilExt on Perfil {
  // Define o tom de voz e títulos na UI
  String get saudacao => switch (this) {
    Perfil.crianca   => "Olá, Pequeno Gênio! 🌟",
    Perfil.adulto    => "Bem-vindo de volta!",
    Perfil.professor => "Painel do Educador",
  };

  // Define qual coleção de perguntas buscar no Firestore ou lógica de IA
  String get prefixoConteudo => switch (this) {
    Perfil.crianca   => "edu_infantil",
    Perfil.adulto    => "edu_eja",
    Perfil.professor => "edu_avancado",
  };

  // Se o perfil tem acesso a relatórios detalhados
  bool get temAcessoDashboards => this == Perfil.professor;
}