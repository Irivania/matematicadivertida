import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  final Set<String> _historico = {};
  static const int _maxHistorico = 50;

  String _id(Pergunta p) => "${p.pergunta}_${p.resposta}";

  // =========================
  // 🔥 COMPATIBILIDADE COM SEU JOGO ATUAL
  // =========================
  Pergunta gerarSimples() {
    return _adicaoFacil();
  }

  // =========================
  // ENTRY UNIVERSAL (NOVO SISTEMA)
  // =========================
  Pergunta gerar({
    required String perfil,
    required String nivel,
    required int fase,
  }) {
    Pergunta pergunta;
    int tentativas = 0;

    do {
      if (perfil == "crianca") {
        pergunta = _gerarCrianca(nivel, fase);
      } else if (perfil == "adulto") {
        pergunta = _gerarAdulto(nivel, fase);
      } else {
        pergunta = _gerarProfessor(nivel, fase);
      }

      tentativas++;

      if (tentativas >= 5) {
        _historico.clear();
        break;
      }
    } while (_historico.contains(_id(pergunta)));

    _historico.add(_id(pergunta));

    if (_historico.length > _maxHistorico) {
      _historico.clear();
    }

    return pergunta;
  }

  // =========================
  // 👶 CRIANÇA
  // =========================
  Pergunta _gerarCrianca(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        if (fase <= 3) return _adicaoFacil();
        if (fase <= 6) return _subtracaoFacil();
        return _problemaSimples();

      case "Prata":
        if (fase <= 3) return _adicaoMedia();
        if (fase <= 6) return _subtracaoMedia();
        return _multiplicacaoFacil();

      case "Ouro":
        if (fase <= 3) return _multiplicacaoMedia();
        if (fase <= 6) return _divisao();
        return _problemaMedio();

      case "Platina":
        if (fase <= 3) return _divisao();
        if (fase <= 6) return _problemaMedio();
        return _fracao();

      case "Mestre":
        if (fase <= 3) return _fracao();
        if (fase <= 6) return _porcentagem();
        return _problemaDificil();
    }

    return _adicaoFacil();
  }

  // =========================
  // 🧑 ADULTO
  // =========================
  Pergunta _gerarAdulto(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        if (fase <= 3) return _multiplicacaoMedia();
        if (fase <= 6) return _divisao();
        return _potenciaSimples();

      case "Prata":
        if (fase <= 3) return _fracao();
        if (fase <= 6) return _numeroNegativo();
        return _expressaoNumerica();

      case "Ouro":
        if (fase <= 3) return _equacao1Grau();
        if (fase <= 6) return _porcentagem();
        return _regraDeTres();

      case "Platina":
        if (fase <= 3) return _equacao1Grau();
        if (fase <= 6) return _raizQuadrada();
        return _problemaDificil();

      case "Mestre":
        return _random([
          _equacao1Grau,
          _porcentagem,
          _regraDeTres,
          _raizQuadrada,
          _problemaDificil,
        ]);
    }

    return _adicaoMedia();
  }

  // =========================
  // 👨‍🏫 PROFESSOR
  // =========================
  Pergunta _gerarProfessor(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        if (fase <= 3) return _fracao();
        if (fase <= 6) return _porcentagem();
        return _problemaMedio();

      case "Prata":
        if (fase <= 3) return _numeroNegativo();
        if (fase <= 6) return _expressaoNumerica();
        return _divisao();

      case "Ouro":
        if (fase <= 3) return _equacao1Grau();
        if (fase <= 6) return _regraDeTres();
        return _porcentagem();

      case "Platina":
        if (fase <= 3) return _equacao1Grau();
        if (fase <= 6) return _potenciaAvancada();
        return _raizQuadrada();

      case "Mestre":
        return _random([
          _equacao1Grau,
          _porcentagem,
          _regraDeTres,
          _potenciaAvancada,
          _problemaDificil,
        ]);
    }

    return _adicaoMedia();
  }

  // =========================
  // RANDOM
  // =========================
  Pergunta _random(List<Function> lista) {
    return lista[rand.nextInt(lista.length)]();
  }

  // =========================
  // BÁSICOS
  // =========================

  Pergunta _adicaoFacil() {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;
    return _base("$a + $b", a + b, "adicao");
  }

  Pergunta _adicaoMedia() {
    int a = rand.nextInt(50) + 10;
    int b = rand.nextInt(50) + 10;
    return _base("$a + $b", a + b, "adicao");
  }

  Pergunta _subtracaoFacil() {
    int a = rand.nextInt(20) + 10;
    int b = rand.nextInt(a);
    return _base("$a - $b", a - b, "subtracao");
  }

  Pergunta _subtracaoMedia() {
    int a = rand.nextInt(100) + 50;
    int b = rand.nextInt(50);
    return _base("$a - $b", a - b, "subtracao");
  }

  Pergunta _multiplicacaoFacil() {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;
    return _base("$a × $b", a * b, "multiplicacao");
  }

  Pergunta _multiplicacaoMedia() {
    int a = rand.nextInt(20) + 5;
    int b = rand.nextInt(10) + 2;
    return _base("$a × $b", a * b, "multiplicacao");
  }

  Pergunta _divisao() {
    int b = rand.nextInt(10) + 2;
    int r = rand.nextInt(10) + 2;
    int a = b * r;
    return _base("$a ÷ $b", r, "divisao");
  }

  // =========================
  // INTERMEDIÁRIO
  // =========================

  Pergunta _potenciaSimples() {
    int n = rand.nextInt(10) + 2;
    return _base("$n²", n * n, "potencia");
  }

  Pergunta _numeroNegativo() {
    int a = rand.nextInt(20);
    int b = rand.nextInt(20);
    return _base("$a - $b", a - b, "negativo");
  }

  Pergunta _expressaoNumerica() {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;
    int c = rand.nextInt(10) + 1;
    int r = a + b * c;
    return _base("$a + $b × $c", r, "expressao");
  }

  Pergunta _equacao1Grau() {
    int x = rand.nextInt(10) + 1;
    int a = rand.nextInt(5) + 1;
    int b = rand.nextInt(10);
    int r = a * x + b;

    return _comOpcoes("$a x + $b = $r. x = ?", x, "equacao");
  }

  Pergunta _regraDeTres() {
    int a = 2;
    int b = rand.nextInt(10) + 2;
    int c = rand.nextInt(5) + 1;
    int x = (b * c) ~/ a;

    return _base("Se $a custa $b, quanto custa $c?", x, "regra3");
  }

  // =========================
  // AVANÇADO
  // =========================

  Pergunta _raizQuadrada() {
    int n = rand.nextInt(15) + 2;
    int num = n * n;
    return _base("√$num", n, "raiz");
  }

  Pergunta _potenciaAvancada() {
    int base = rand.nextInt(5) + 2;
    int exp = rand.nextInt(3) + 2;
    int r = pow(base, exp).toInt();
    return _base("$base^$exp", r, "potencia");
  }

  Pergunta _fracao() {
    return _comOpcoes("Qual é metade de 20?", 10, "fracao");
  }

  Pergunta _porcentagem() {
    return _comOpcoes("10% de 50 é:", 5, "porcentagem");
  }

  // =========================
  // PROBLEMAS
  // =========================

  Pergunta _problemaSimples() {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;

    return _base(
      "João tinha $a balas e ganhou mais $b. Quantas tem agora?",
      a + b,
      "problema",
    );
  }

  Pergunta _problemaMedio() {
    int preco = rand.nextInt(20) + 5;
    int qtd = rand.nextInt(5) + 2;

    return _base(
      "Um produto custa R\$ $preco. Se comprar $qtd, quanto paga?",
      preco * qtd,
      "problema",
    );
  }

  Pergunta _problemaDificil() {
    int total = rand.nextInt(100) + 50;
    int pessoas = rand.nextInt(5) + 2;

    return _base(
      "Dividir $total igualmente entre $pessoas pessoas. Quanto cada recebe?",
      total ~/ pessoas,
      "problema",
    );
  }

  // =========================
  // HELPERS
  // =========================

  Pergunta _base(String exp, int resultado, String tipo) {
    return Pergunta(
      pergunta: "Quanto é $exp =",
      resposta: resultado.toString(),
      tipo: tipo,
    );
  }

  Pergunta _comOpcoes(String pergunta, int correta, String tipo) {
    return Pergunta(
      pergunta: pergunta,
      resposta: correta.toString(),
      tipo: tipo,
      opcoes: _gerarOpcoes(correta),
    );
  }

  List<String> _gerarOpcoes(int correta) {
    Set<int> opcoes = {correta};

    while (opcoes.length < 4) {
      opcoes.add(correta + rand.nextInt(10) - 5);
    }

    return opcoes.map((e) => e.toString()).toList()..shuffle();
  }
}