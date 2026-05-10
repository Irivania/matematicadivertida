import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  // Histórico anti-repetição
  final List<String> _historico = [];
  static const int _maxHistorico = 50;

  String _id(Pergunta p) => "${p.pergunta}_${p.resposta}";

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

    final pNorm = perfil.toLowerCase().trim();

    do {
      pergunta = switch (pNorm) {
        "crianca" || "criança" => _gerarCrianca(nivel, fase),
        "adulto" => _gerarAdulto(nivel, fase),
        _ => _gerarProfessor(nivel, fase), 
      };

      tentativas++;

      if (tentativas >= 5) {
        _historico.clear();
      }
    } while (_historico.contains(_id(pergunta)));

    _historico.add(_id(pergunta));

    if (_historico.length > _maxHistorico) {
      _historico.removeAt(0);
    }

    return pergunta;
  }

  // =====================================================
  // 👶 PERFIL: CRIANÇA
  // =====================================================

  Pergunta _gerarCrianca(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        return fase <= 3 ? _operacaoBasica("+", 1, 10) : _operacaoBasica("-", 5, 15);
      case "Prata":
        return fase <= 3 ? _operacaoBasica("×", 2, 5) : _problemaSimples();
      case "Ouro":
        return fase <= 3 ? _divisao() : _problemaMedio();
      case "Platina":
        return fase <= 3 ? _fracaoSimples() : _porcentagemBasica();
      case "Mestre":
        return _problemaDificil();
      default:
        return _operacaoBasica("+", 1, 10);
    }
  }

  // =====================================================
  // 🧑 PERFIL: ADULTO
  // =====================================================

  Pergunta _gerarAdulto(String nivel, int fase) {
    switch (nivel) {
      case "Bronze":
        return fase <= 3 ? _operacaoBasica("×", 5, 12) : _divisao();
      case "Prata":
        return fase <= 3 ? _numeroNegativo() : _expressaoNumerica();
      case "Ouro":
        return fase <= 3 ? _equacao1Grau() : _porcentagemAvancada();
      case "Platina":
        return fase <= 3 ? _regraDeTres() : _raizQuadrada();
      case "Mestre":
        return _random([_equacao1Grau, _regraDeTres, _raizQuadrada, _potenciaAvancada]);
      default:
        return _operacaoBasica("+", 10, 50);
    }
  }

  // =====================================================
  // 👨‍🏫 PERFIL: PROFESSOR
  // =====================================================

  Pergunta _gerarProfessor(String nivel, int fase) {
    switch (nivel) {
      case "Bronze": return _expressaoNumerica();
      case "Prata": return _equacao1Grau();
      case "Ouro": return _regraDeTres();
      case "Platina": return _potenciaAvancada();
      case "Mestre": return _random([_equacao1Grau, _potenciaAvancada, _raizQuadrada, _problemaDificil]);
      default: return _operacaoBasica("×", 12, 30);
    }
  }

  // =====================================================
  // 🎲 GERADORES DE OPERAÇÕES
  // =====================================================

  Pergunta _random(List<Function> lista) => lista[rand.nextInt(lista.length)]();

  Pergunta _operacaoBasica(String op, int min, int max) {
    int a = rand.nextInt(max - min) + min;
    int b = rand.nextInt(max - min) + min;
    if (op == "-" && a < b) { final temp = a; a = b; b = temp; }
    int resultado = switch (op) {
      "+" => a + b,
      "-" => a - b,
      "×" => a * b,
      _ => a + b,
    };
    return _base("$a $op $b", resultado, op);
  }

  Pergunta _divisao() {
    int b = rand.nextInt(8) + 2;
    int r = rand.nextInt(9) + 2;
    int a = b * r;
    return _base("$a ÷ $b", r, "divisao");
  }

  Pergunta _equacao1Grau() {
    int x = rand.nextInt(10) + 1;
    int a = rand.nextInt(5) + 2;
    int b = rand.nextInt(10) + 1;
    int r = (a * x) + b;
    return _base("$a x + $b = $r. O x", x, "equacao");
  }

  Pergunta _porcentagemBasica() {
    final valores = [50, 100, 200];
    int valor = valores[rand.nextInt(valores.length)];
    return _base("10% de $valor", valor ~/ 10, "porcentagem");
  }

  Pergunta _porcentagemAvancada() {
    int valor = (rand.nextInt(9) + 1) * 100;
    int perc = (rand.nextInt(3) + 1) * 15;
    int r = (valor * perc) ~/ 100;
    return _base("$perc% de $valor", r, "porcentagem");
  }

  Pergunta _regraDeTres() {
    int a = 2;
    int b = (rand.nextInt(10) + 2) * 2;
    int c = rand.nextInt(5) + 3;
    int x = (b * c) ~/ a;
    return _base("Se $a itens custam $b, $c", x, "regra3");
  }

  Pergunta _potenciaAvancada() {
    int base = rand.nextInt(3) + 2;
    int exp = rand.nextInt(3) + 3;
    int r = pow(base, exp).toInt();
    return _base("$base^$exp", r, "potencia");
  }

  Pergunta _raizQuadrada() {
    int n = rand.nextInt(11) + 5; 
    return _base("√${n * n}", n, "raiz");
  }

  Pergunta _numeroNegativo() {
    int a = rand.nextInt(10);
    int b = rand.nextInt(10) + a + 1;
    return _base("$a - $b", a - b, "negativo");
  }

  Pergunta _expressaoNumerica() {
    int a = rand.nextInt(10) + 2;
    int b = rand.nextInt(5) + 2;
    int c = rand.nextInt(10) + 1;
    int r = a + (b * c);
    return _base("$a + $b × $c", r, "expressao");
  }

  Pergunta _problemaDificil() {
    int total = (rand.nextInt(50) + 25) * 2;
    return _base("metade de $total + 15", (total ~/ 2) + 15, "problema");
  }

  Pergunta _problemaSimples() => _operacaoBasica("+", 10, 40);
  Pergunta _problemaMedio() => _operacaoBasica("×", 3, 9);
  Pergunta _fracaoSimples() => _base("a metade de ${rand.nextInt(15) * 2}", 0, "fracao");

  // =====================================================
  // 🛠 HELPER DE FORMATAÇÃO (Onde a mágica acontece)
  // =====================================================

  Pergunta _base(String exp, int resultado, String tipo) {
    // 1. Padroniza o início com "Quanto é?"
    // 2. Remove espaços extras e garante o sinal de igual no final
    String questao = "Quanto é $exp =";

    // Pequeno ajuste para não ficar "Quanto é Quanto é" caso você passe uma string já montada
    if (exp.toLowerCase().contains("quanto é")) {
      questao = "$exp =";
    }

    return Pergunta(
      pergunta: questao,
      resposta: resultado.toString(),
      tipo: tipo,
    );
  }
}