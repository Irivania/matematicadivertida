import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  // Histórico anti-repetição
  final List<String> _historico = [];

  static const int _maxHistorico = 50;

  String _id(Pergunta p) => "${p.pergunta}_${p.resposta}";

  // =====================================================
  // 🔥 COMPATIBILIDADE COM O JOGO ANTIGO
  // =====================================================

  Pergunta gerarSimples() {
    return _operacaoBasica("+", 1, 10);
  }

  // =====================================================
  // 🚀 ENTRADA UNIVERSAL
  // =====================================================

  Pergunta gerar({
    required String perfil,
    required String nivel,
    required int fase,
  }) {
    Pergunta pergunta;

    int tentativas = 0;

    do {
      pergunta = switch (perfil) {
        "crianca" => _gerarCrianca(nivel, fase),
        "adulto" => _gerarAdulto(nivel, fase),
        _ => _gerarProfessor(nivel, fase),
      };

      tentativas++;

      // Evita loop infinito
      if (tentativas >= 5) {
        _historico.clear();
      }
    } while (_historico.contains(_id(pergunta)));

    _historico.add(_id(pergunta));

    // Mantém histórico controlado
    if (_historico.length > _maxHistorico) {
      _historico.removeAt(0);
    }

    return pergunta;
  }

  // =====================================================
  // 👶 CRIANÇA
  // =====================================================

  Pergunta _gerarCrianca(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        return fase <= 3
            ? _operacaoBasica("+", 1, 10)
            : fase <= 6
                ? _operacaoBasica("-", 10, 20)
                : _problemaSimples();

      case "Prata":
        return fase <= 3
            ? _operacaoBasica("+", 10, 50)
            : fase <= 6
                ? _operacaoBasica("-", 50, 100)
                : _operacaoBasica("×", 2, 10);

      case "Ouro":
        return fase <= 3
            ? _operacaoBasica("×", 5, 20)
            : fase <= 6
                ? _divisao()
                : _problemaMedio();

      case "Platina":
        return fase <= 3
            ? _divisao()
            : fase <= 6
                ? _problemaMedio()
                : _fracao();

      case "Mestre":
        return fase <= 3
            ? _fracao()
            : fase <= 6
                ? _porcentagem()
                : _problemaDificil();

      default:
        return _operacaoBasica("+", 1, 10);
    }
  }

  // =====================================================
  // 🧑 ADULTO
  // =====================================================

  Pergunta _gerarAdulto(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        return fase <= 3
            ? _operacaoBasica("×", 5, 20)
            : fase <= 6
                ? _divisao()
                : _potenciaSimples();

      case "Prata":
        return fase <= 3
            ? _fracao()
            : fase <= 6
                ? _numeroNegativo()
                : _expressaoNumerica();

      case "Ouro":
        return fase <= 3
            ? _equacao1Grau()
            : fase <= 6
                ? _porcentagem()
                : _regraDeTres();

      case "Platina":
        return fase <= 3
            ? _equacao1Grau()
            : fase <= 6
                ? _raizQuadrada()
                : _problemaDificil();

      case "Mestre":
        return _random([
          _equacao1Grau,
          _porcentagem,
          _regraDeTres,
          _raizQuadrada,
          _problemaDificil,
        ]);

      default:
        return _operacaoBasica("+", 10, 50);
    }
  }

  // =====================================================
  // 👨‍🏫 PROFESSOR
  // =====================================================

  Pergunta _gerarProfessor(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        return fase <= 3
            ? _fracao()
            : fase <= 6
                ? _porcentagem()
                : _problemaMedio();

      case "Prata":
        return fase <= 3
            ? _numeroNegativo()
            : fase <= 6
                ? _expressaoNumerica()
                : _divisao();

      case "Ouro":
        return fase <= 3
            ? _equacao1Grau()
            : fase <= 6
                ? _regraDeTres()
                : _porcentagem();

      case "Platina":
        return fase <= 3
            ? _equacao1Grau()
            : fase <= 6
                ? _potenciaAvancada()
                : _raizQuadrada();

      case "Mestre":
        return _random([
          _equacao1Grau,
          _porcentagem,
          _regraDeTres,
          _potenciaAvancada,
          _problemaDificil,
        ]);

      default:
        return _operacaoBasica("+", 10, 50);
    }
  }

  // =====================================================
  // 🎲 RANDOM
  // =====================================================

  Pergunta _random(List<Function> lista) {
    return lista[rand.nextInt(lista.length)]();
  }

  // =====================================================
  // 🔢 OPERAÇÕES PARAMETRIZADAS
  // =====================================================

  Pergunta _operacaoBasica(String op, int min, int max) {
    int a = rand.nextInt(max - min) + min;
    int b = rand.nextInt(max - min) + min;

    int resultado = switch (op) {
      "+" => a + b,
      "-" => a - b,
      "×" => a * b,
      "÷" => b == 0 ? a : a ~/ b,
      _ => 0,
    };

    return _base("$a $op $b", resultado, op);
  }

  // =====================================================
  // 📘 INTERMEDIÁRIO / AVANÇADO
  // =====================================================

  Pergunta _divisao() {
    int b = rand.nextInt(9) + 2;
    int r = rand.nextInt(9) + 2;

    int a = b * r;

    return _base("$a ÷ $b", r, "divisao");
  }

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

    return _comOpcoes(
      "$a x + $b = $r. x = ?",
      x,
      "equacao",
    );
  }

  Pergunta _regraDeTres() {
    int a = 2;
    int b = rand.nextInt(10) + 2;
    int c = rand.nextInt(5) + 1;

    int x = (b * c) ~/ a;

    return _base(
      "Se $a custa $b, quanto custa $c?",
      x,
      "regra3",
    );
  }

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
    return _comOpcoes(
      "Qual é metade de 20?",
      10,
      "fracao",
    );
  }

  Pergunta _porcentagem() {
    return _comOpcoes(
      "10% de 50 é:",
      5,
      "porcentagem",
    );
  }

  // =====================================================
  // 🧠 PROBLEMAS
  // =====================================================

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

  // =====================================================
  // 🛠 HELPERS
  // =====================================================

  Pergunta _base(
    String exp,
    int resultado,
    String tipo,
  ) {
    return Pergunta(
      pergunta: "Quanto é $exp =",
      resposta: resultado.toString(),
      tipo: tipo,
    );
  }

  Pergunta _comOpcoes(
    String pergunta,
    int correta,
    String tipo,
  ) {
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
      int candidato = correta + rand.nextInt(10) - 5;

      if (candidato >= 0) {
        opcoes.add(candidato);
      }
    }

    return opcoes
        .map((e) => e.toString())
        .toList()
      ..shuffle();
  }
}