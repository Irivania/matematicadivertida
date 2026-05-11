import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  // Histórico anti-repetição otimizado
  final Set<String> _historico = {};
  final List<String> _ordemHistorico = [];
  static const int _maxHistorico = 30;

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
      // Switch expression para selecionar o perfil
      pergunta = switch (pNorm) {
        "crianca" || "criança" => _gerarCrianca(nivel, fase),
        "adulto" => _gerarAdulto(nivel, fase),
        _ => _gerarProfessor(nivel, fase),
      };

      tentativas++;
      // Se travar em repetições, limpa o rastro para não quebrar o jogo
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
      "Bronze" => fase <= 3 ? _operacaoBasica("+", 1, 10) : _operacaoBasica("-", 5, 15),
      "Prata"  => fase <= 3 ? _operacaoBasica("×", 2, 5) : _problemaSimples(),
      "Ouro"   => fase <= 3 ? _divisao() : _problemaMedio(),
      "Platina"=> fase <= 3 ? _fracaoSimples() : _porcentagemBasica(),
      "Mestre" => _problemaDificil(),
      _        => _operacaoBasica("+", 1, 10),
    };
  }

  // =====================================================
  // 🧑 PERFIL: ADULTO
  // =====================================================

  Pergunta _gerarAdulto(String nivel, int fase) {
    return switch (nivel) {
      "Bronze" => fase <= 3 ? _operacaoBasica("×", 5, 12) : _divisao(),
      "Prata"  => fase <= 3 ? _numeroNegativo() : _expressaoNumerica(),
      "Ouro"   => fase <= 3 ? _equacao1Grau() : _porcentagemAvancada(),
      "Platina"=> fase <= 3 ? _regraDeTres() : _raizQuadrada(),
      "Mestre" => _random([_equacao1Grau, _regraDeTres, _raizQuadrada, _potenciaAvancada]),
      _        => _operacaoBasica("+", 10, 50),
    };
  }

  // =====================================================
  // 👨‍🏫 PERFIL: PROFESSOR
  // =====================================================

  Pergunta _gerarProfessor(String nivel, int fase) {
    return switch (nivel) {
      "Bronze" => _expressaoNumerica(),
      "Prata"  => _equacao1Grau(),
      "Ouro"   => _regraDeTres(),
      "Platina"=> _potenciaAvancada(),
      "Mestre" => _random([_equacao1Grau, _potenciaAvancada, _raizQuadrada, _problemaDificil]),
      _        => _operacaoBasica("×", 12, 30),
    };
  }

  // =====================================================
  // 🎲 GERADORES DE OPERAÇÕES
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

  Pergunta _equacao1Grau() {
    int x = rand.nextInt(10) + 1;
    int a = rand.nextInt(5) + 2;
    int b = rand.nextInt(10) + 1;
    int r = (a * x) + b;
    return _base("$a x + $b = $r. Qual o valor de x?", x, "equacao");
  }

  // Adicionado parâmetro 'tipo' fixo para porcentagem básica
  Pergunta _porcentagemBasica() {
    final valores = [50, 100, 200, 500];
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
    return _base("Se $a itens custam $b, quanto custam $c?", x, "regra3");
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
    return _base("$a + $b × $c", a + (b * c), "expressao");
  }

  Pergunta _problemaDificil() {
    int total = (rand.nextInt(50) + 25) * 2;
    return _base("A metade de $total somada com 15", (total ~/ 2) + 15, "problema");
  }

  Pergunta _problemaSimples() => _operacaoBasica("+", 10, 40);
  Pergunta _problemaMedio() => _operacaoBasica("×", 3, 9);
  
  Pergunta _fracaoSimples() {
    int n = (rand.nextInt(15) + 1) * 2;
    return _base("a metade de $n", n ~/ 2, "fracao");
  }

  // =====================================================
  // 🛠 HELPER DE FORMATAÇÃO E DICAS (A Mágica Ajustada)
  // =====================================================

  Pergunta _base(String exp, int resultado, String tipo) {
    String questao = exp.trim();
    
    // Garante prefixo "Quanto é" se não houver
    if (!questao.toLowerCase().startsWith("quanto") && !questao.contains("?")) {
      questao = "Quanto é $questao";
    }

    // Garante sufixo de igual ou interrogação
    if (!questao.endsWith("?") && !questao.endsWith("=")) {
      questao = "$questao =";
    }

    // --- NOVA LÓGICA DE DETECÇÃO DE ORDEM DAS OPERAÇÕES (PEMDAS) ---
    String dica = "";

    // 1. Detecta se é uma expressão com múltiplas operações (adição/subtração E multiplicação/divisão)
    // Usamos regex ou verificações simples para encontrar os símbolos
    bool temSomaOuSub = exp.contains('+') || exp.contains('-');
    bool temMultOuDiv = exp.contains('×') || exp.contains('*') || exp.contains('÷') || exp.contains('/');

    if (temSomaOuSub && temMultOuDiv) {
      // Dica técnica e específica para a Ordem das Operações, ideal para o perfil Professor
      dica = "Lembre-se da ordem das operações! Multiplicações e divisões devem ser resolvidas *antes* de adições e subtrações.";
    } else {
      // Mantém as dicas pedagógicas simples para contas de uma única operação
      dica = switch (tipo) {
        "basica" && _ when exp.contains('+') => "Somar é juntar quantidades! Se você ganha mais alguns, com quantos fica no total?",
        "basica" && _ when exp.contains('-') => "Subtrair é tirar uma parte de algo. Se você retira um valor, quanto sobra?",
        "basica" && _ when exp.contains('×') || exp.contains('*') => "Multiplicar é uma forma rápida de somar o mesmo número várias vezes!",
        "divisao"    => "Dividir é repartir em partes iguais. Pense em distribuir doces entre amigos!",
        "equacao"    => "O 'x' é um número escondido. Tente fazer a conta inversa para descobrir quem ele é!",
        "porcentagem"=> "Porcentagem é uma parte de 100. 10% é o mesmo que dividir o valor por 10!",
        "fracao"     => "Frações representam partes de um todo. A metade é sempre dividir o número por 2.",
        "raiz"       => "A raiz quadrada procura qual número multiplicado por ele mesmo resulta no valor dentro do símbolo.",
        _            => "Analise a conta com calma. Respire fundo, você consegue resolver!"
      };
    }

    return Pergunta(
      pergunta: questao,
      resposta: resultado.toString(),
      tipo: tipo,
      dica: dica,
    );
  }

  // Helpers do Histórico
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