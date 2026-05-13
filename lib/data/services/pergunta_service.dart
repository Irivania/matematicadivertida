import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  // Histórico anti-repetição otimizado
  final Set<String> _historico = {};
  final List<String> _ordemHistorico = [];
  static const int _maxHistorico = 30;

  String _id(Pergunta p) => "${p.tipo}_${p.pergunta}_${p.resposta}";

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
      if (tentativas >= 5) _limparHistorico();
    } while (_historico.contains(_id(pergunta)));

    _adicionarAoHistorico(pergunta);
    return pergunta;
  }

  // =====================================================
  // 👶 PERFIL: CRIANÇA
  // =====================================================

  Pergunta _gerarCrianca(String nivel, int fase) {
    return switch (nivel) {
      "Bronze" => fase <= 3 
          ? _operacaoBasica("+", 1, 10 + fase) 
          : _operacaoBasica("-", 5, 15 + fase),
      "Prata"  => fase <= 3 
          ? _operacaoBasica("×", 2, 5) 
          : _problemaSimples(),
      "Ouro"   => fase <= 3 ? _divisao() : _problemaMedio(),
      "Platina"=> fase <= 3 ? _fracaoSimples() : _porcentagemBasica(),
      "Mestre" => _problemaDificil(fase),
      _        => _operacaoBasica("+", 1, 10),
    };
  }

  // =====================================================
  // 🧑 PERFIL: ADULTO
  // =====================================================

  Pergunta _gerarAdulto(String nivel, int fase) {
    return switch (nivel) {
      "Bronze" => fase <= 3 ? _operacaoBasica("×", 5, 12) : _divisao(),
      "Prata"  => fase <= 3 ? _numeroNegativo() : _expressaoNumerica(fase),
      "Ouro"   => fase <= 3 ? _equacao1Grau(fase) : _porcentagemAvancada(),
      "Platina"=> fase <= 3 ? _regraDeTres() : _raizQuadrada(),
      "Mestre" => _random([
          () => _equacao1Grau(fase), 
          _regraDeTres, 
          _raizQuadrada, 
          _potenciaAvancada
        ]),
      _        => _operacaoBasica("+", 10, 50),
    };
  }

  // =====================================================
  // 👨‍🏫 PERFIL: PROFESSOR
  // =====================================================

  Pergunta _gerarProfessor(String nivel, int fase) {
    return switch (nivel) {
      "Bronze" => _expressaoNumerica(fase),
      "Prata"  => _equacao1Grau(fase),
      "Ouro"   => _regraDeTres(),
      "Platina"=> _potenciaAvancada(),
      "Mestre" => _random([
          () => _equacao1Grau(fase + 5), 
          _potenciaAvancada, 
          _raizQuadrada, 
          () => _problemaDificil(fase)
        ]),
      _        => _operacaoBasica("×", 12, 30),
    };
  }

  // =====================================================
  // 🎲 GERADORES
  // =====================================================

  Pergunta _operacaoBasica(String op, int min, int max) {
    int a = rand.nextInt(max - min) + min;
    int b = rand.nextInt(max - min) + min;
    if (op == "-" && a < b) { final temp = a; a = b; b = temp; }
    
    int resultado = switch (op) {
      "+" => a + b,
      "-" => a - b,
      "×" => a * b,
      _   => a + b,
    };
    return _base("$a $op $b", resultado, "basica");
  }

  Pergunta _divisao() {
    int b = rand.nextInt(8) + 2;
    int r = rand.nextInt(9) + 2;
    return _base("${b * r} ÷ $b", r, "divisao");
  }

  Pergunta _equacao1Grau(int fase) {
    int x = rand.nextInt(10) + 1;
    int a = rand.nextInt(5) + 2;
    int b = rand.nextInt(10 + fase) + 1;
    int r = (a * x) + b;
    return _base("$a x + $b = $r. Qual o valor de x?", x, "equacao");
  }

  Pergunta _porcentagemBasica() {
    final valores = [50, 100, 200, 500, 1000];
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
    return _base("Se $a itens custam R\$ $b, quanto custam $c?", x, "regra3");
  }

  Pergunta _potenciaAvancada() {
    int b = rand.nextInt(3) + 2;
    int e = rand.nextInt(3) + 3;
    int r = pow(b, e).toInt();
    return _base("$b^$e", r, "potencia");
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

  Pergunta _expressaoNumerica(int fase) {
    int a = rand.nextInt(10) + 2;
    int b = rand.nextInt(5) + 2;
    int c = rand.nextInt(10 + fase) + 1;
    return _base("$a + $b × $c", a + (b * c), "expressao");
  }

  Pergunta _fracaoSimples() {
    final denominadores = [2, 3, 4, 5];
    int den = denominadores[rand.nextInt(denominadores.length)];
    int r = rand.nextInt(6) + 1;
    int n = r * den;
    
    String termo = switch(den) {
      2 => "a metade",
      3 => "a terça parte",
      4 => "a quarta parte",
      5 => "a quinta parte",
      _ => "a parte"
    };

    return _base("Quanto é $termo de $n?", r, "fracao");
  }

  Pergunta _problemaDificil(int fase) {
    int total = (rand.nextInt(50) + 20) * 2;
    int extra = 10 + fase;
    return _base("A metade de $total somada com $extra", (total ~/ 2) + extra, "problema");
  }

  Pergunta _problemaSimples() => _operacaoBasica("+", 15, 45);
  Pergunta _problemaMedio() => _operacaoBasica("×", 4, 12);

  // =====================================================
  // 🛠 HELPER DE FORMATAÇÃO E DICAS (LIMPO)
  // =====================================================

  Pergunta _base(String exp, int resultado, String tipo) {
    String questao = exp.trim();
    
    if (!questao.toLowerCase().contains("quanto") && 
        !questao.toLowerCase().contains("se") && 
        !questao.contains("?")) {
      questao = "Quanto é $questao";
    }

    if (!questao.endsWith("?") && !questao.endsWith("=")) {
      questao = "$questao =";
    }

    String dica = "";
    bool temSomaOuSub = exp.contains('+') || exp.contains('-');
    bool temMultOuDiv = exp.contains('×') || exp.contains('÷');

    if (temSomaOuSub && temMultOuDiv) {
      dica = "⚠️ Ordem das Operações: Resolva as multiplicações ou divisões primeiro, depois faça a soma ou subtração!";
    } else {
      // DICAS LIMPAS SEM WILDCARDS DESNECESSÁRIOS
      dica = switch (tipo) {
        "basica" when exp.contains('+') => "Somar é o mesmo que juntar quantidades!",
        "basica" when exp.contains('-') => "Na subtração, você descobre quanto sobra ao tirar uma parte.",
        "basica" when exp.contains('×') => "A multiplicação é uma soma repetida. $exp significa somar o mesmo número várias vezes.",
        "divisao"     => "Dividir é repartir um valor em partes iguais.",
        "equacao"     => "Pense no 'x' como um buraco vazio que você precisa preencher para a conta dar certo.",
        "porcentagem" => "Porcentagem é uma parte de 100. Dica: 10% é só dividir por 10!",
        "fracao"      => "Frações são pedaços de um todo. Divida o número pelo denominador indicado.",
        "raiz"        => "Qual número que, multiplicado por ele mesmo, resulta no valor que está dentro da raiz?",
        "regra3"      => "Tente descobrir o valor de 1 unidade primeiro para depois multiplicar pela quantidade desejada.",
        _             => "Leia com atenção e resolva um passo de cada vez. Você consegue!"
      };
    }

    return Pergunta(
      pergunta: questao,
      resposta: resultado.toString(),
      tipo: tipo,
      dica: dica,
    );
  }

  void _adicionarAoHistorico(Pergunta p) {
    String id = _id(p);
    if (_historico.length >= _maxHistorico) {
      String antigo = _ordemHistorico.removeAt(0);
      _historico.remove(antigo);
    }
    _historico.add(id);
    _ordemHistorico.add(id);
  }

  void _limparHistorico() {
    _historico.clear();
    _ordemHistorico.clear();
  }

  Pergunta _random(List<Function> lista) => lista[rand.nextInt(lista.length)]();
}