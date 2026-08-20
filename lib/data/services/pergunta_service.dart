// lib/data/services/pergunta_service.dart
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
  // 🚀 MÉTODOS DE CONTROLE
  // =====================================================

  void resetarExperiencia() => _limparHistorico();

  // =====================================================
  // 🚀 ENTRADA UNIVERSAL (Com suporte a idioma)
  // =====================================================

  Pergunta gerar({
    required String perfil,
    required String nivel,
    required int fase,
    String languageCode = 'pt', // <- Parâmetro opcional para o idioma ('pt' ou 'en')
  }) {
    Pergunta pergunta;
    int tentativas = 0;
    final pNorm = perfil.toLowerCase().trim();

    do {
      pergunta = switch (pNorm) {
        "crianca" || "criança" => _gerarCrianca(nivel, fase, languageCode),
        "adulto" => _gerarAdulto(nivel, fase, languageCode),
        _ => _gerarProfessor(nivel, fase, languageCode),
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

  Pergunta _gerarCrianca(String nivel, int fase, String lang) {
    return switch (nivel) {
      "Bronze" => fase <= 3 
          ? _operacaoBasica("+", 1, 10 + fase, fase, lang) 
          : _operacaoBasica("-", 5, 15 + fase, fase, lang),
      "Prata"  => fase <= 3 
          ? _operacaoBasica("×", 2, 5 + (fase * 2), fase, lang) 
          : _problemaSimples(lang),
      "Ouro"   => fase <= 3 ? _divisao(lang) : _problemaMedio(lang),
      "Platina"=> fase <= 3 ? _fracaoSimples(lang) : _porcentagemBasica(lang),
      "Mestre" => _problemaDificil(fase, lang),
      _        => _operacaoBasica("+", 1, 10, fase, lang),
    };
  }

  // =====================================================
  // 🧑 PERFIL: ADULTO
  // =====================================================

  Pergunta _gerarAdulto(String nivel, int fase, String lang) {
    return switch (nivel) {
      "Bronze" => fase <= 3 ? _operacaoBasica("×", 5, 12, fase, lang) : _divisao(lang),
      "Prata"  => fase <= 3 ? _numeroNegativo(lang) : _expressaoNumerica(fase, lang),
      "Ouro"   => fase <= 3 ? _equacao1Grau(fase, lang) : _porcentagemAvancada(lang),
      "Platina"=> fase <= 3 ? _regraDeTres(lang) : _raizQuadrada(lang),
      "Mestre" => _random([
          () => _equacao1Grau(fase, lang), 
          () => _regraDeTres(lang), 
          () => _raizQuadrada(lang), 
          () => _potenciaAvancada(lang)
        ]),
      _        => _operacaoBasica("+", 10, 50, fase, lang),
    };
  }

  // =====================================================
  // 👨‍🏫 PERFIL: PROFESSOR
  // =====================================================

  Pergunta _gerarProfessor(String nivel, int fase, String lang) {
    return switch (nivel) {
      "Bronze" => _expressaoNumerica(fase, lang),
      "Prata"  => _equacao1Grau(fase, lang),
      "Ouro"   => _regraDeTres(lang),
      "Platina"=> _potenciaAvancada(lang),
      "Mestre" => _random([
          () => _equacao1Grau(fase + 5, lang), 
          () => _potenciaAvancada(lang), 
          () => _raizQuadrada(lang), 
          () => _problemaDificil(fase, lang)
        ]),
      _        => _operacaoBasica("×", 12, 30, fase, lang),
    };
  }

  // =====================================================
  // 🎲 GERADORES COM SUPORTE A IDIOMA
  // =====================================================

  Pergunta _operacaoBasica(String op, int minBase, int maxBase, int fase, String lang) {
    int max = maxBase + (fase * 2);
    int a = rand.nextInt(max - minBase) + minBase;
    int b = rand.nextInt(max - minBase) + minBase;
    if (op == "-" && a < b) { final temp = a; a = b; b = temp; }
    
    num resultado = switch (op) {
      "+" => a + b,
      "-" => a - b,
      "×" => a * b,
      _   => a + b,
    };
    return _base("$a $op $b", resultado, "basica", lang);
  }

  Pergunta _divisao(String lang) {
    int b = rand.nextInt(8) + 2;
    int r = rand.nextInt(9) + 2;
    return _base("${b * r} ÷ $b", b * r / b, "divisao", lang);
  }

  Pergunta _equacao1Grau(int fase, String lang) {
    int x = rand.nextInt(10) + 1;
    int a = rand.nextInt(5) + 2;
    int b = rand.nextInt(10 + fase) + 1;
    int r = (a * x) + b;
    String questao = (lang == 'en') ? "$a x + $b = $r. What is the value of x?" : "$a x + $b = $r. Qual o valor de x?";
    return _base(questao, x, "equacao", lang);
  }

  Pergunta _porcentagemBasica(String lang) {
    final valores = [50, 100, 200, 500, 1000];
    int valor = valores[rand.nextInt(valores.length)];
    String questao = (lang == 'en') ? "10% of $valor" : "10% de $valor";
    return _base(questao, valor / 10, "porcentagem", lang);
  }

  Pergunta _porcentagemAvancada(String lang) {
    int valor = (rand.nextInt(9) + 1) * 100;
    int perc = (rand.nextInt(3) + 1) * 15;
    num r = (valor * perc) / 100;
    String questao = (lang == 'en') ? "$perc% of $valor" : "$perc% de $valor";
    return _base(questao, r, "porcentagem", lang);
  }

  Pergunta _regraDeTres(String lang) {
    int a = 2;
    int b = (rand.nextInt(10) + 2) * 2;
    int c = rand.nextInt(5) + 3;
    num x = (b * c) / a;
    String questao = (lang == 'en') 
        ? "If $a items cost \$$b, how much do $c cost?" 
        : "Se $a itens custam R\$ $b, quanto custam $c?";
    return _base(questao, x, "regra3", lang);
  }

  Pergunta _potenciaAvancada(String lang) {
    int b = rand.nextInt(3) + 2;
    int e = rand.nextInt(3) + 3;
    num r = pow(b, e);
    return _base("$b^$e", r, "potencia", lang);
  }

  Pergunta _raizQuadrada(String lang) {
    int n = rand.nextInt(11) + 5;
    return _base("√${n * n}", n, "raiz", lang);
  }

  Pergunta _numeroNegativo(String lang) {
    int a = rand.nextInt(10);
    int b = rand.nextInt(10) + a + 1;
    return _base("$a - $b", a - b, "negativo", lang);
  }

  Pergunta _expressaoNumerica(int fase, String lang) {
    int a = rand.nextInt(10) + 2;
    int b = rand.nextInt(5) + 2;
    int c = rand.nextInt(10 + fase) + 1;
    return _base("$a + $b × $c", a + (b * c), "expressao", lang);
  }

  Pergunta _fracaoSimples(String lang) {
    final denominadores = [2, 3, 4, 5];
    int den = denominadores[rand.nextInt(denominadores.length)];
    int r = rand.nextInt(6) + 1;
    int n = r * den;
    
    String termo = switch(den) {
      2 => lang == 'en' ? "half" : "a metade", 
      3 => lang == 'en' ? "third" : "a terça parte", 
      4 => lang == 'en' ? "quarter" : "a quarta parte", 
      5 => lang == 'en' ? "fifth" : "a quinta parte",
      _ => lang == 'en' ? "part" : "a parte"
    };
    String questao = lang == 'en' ? "What is $termo of $n?" : "Quanto é $termo de $n?";
    return _base(questao, r, "fracao", lang);
  }

  Pergunta _problemaDificil(int fase, String lang) {
    int total = (rand.nextInt(50) + 20) * 2;
    int extra = 10 + fase;
    String questao = lang == 'en' 
        ? "Half of $total added to $extra" 
        : "A metade de $total somada com $extra";
    return _base(questao, (total / 2) + extra, "problema", lang);
  }

  Pergunta _problemaSimples(String lang) => _operacaoBasica("+", 15, 45, 1, lang);
  Pergunta _problemaMedio(String lang) => _operacaoBasica("×", 4, 12, 1, lang);

  // =====================================================
  // 🛠 HELPER DE FORMATAÇÃO E TRADUÇÃO DAS DICAS
  // =====================================================

  Pergunta _base(String exp, num resultado, String tipo, String lang) {
    String questao = exp.trim();
    String res = (resultado % 1 == 0) ? resultado.toInt().toString() : resultado.toString();

    if (lang == 'en') {
      if (!questao.toLowerCase().contains("what") && !questao.toLowerCase().contains("if") && !questao.contains("?")) {
        questao = "What is $questao";
      }
    } else {
      if (!questao.toLowerCase().contains("quanto") && !questao.toLowerCase().contains("se") && !questao.contains("?")) {
        questao = "Quanto é $questao";
      }
    }

    if (!questao.endsWith("?") && !questao.endsWith("=")) {
      questao = "$questao =";
    }

    String dica = "";
    bool temSomaOuSub = exp.contains('+') || exp.contains('-');
    bool temMultOuDiv = exp.contains('×') || exp.contains('÷');

    if (temSomaOuSub && temMultOuDiv) {
      dica = lang == 'en' 
          ? "⚠️ Order of Operations: Solve multiplications or divisions first!" 
          : "⚠️ Ordem das Operações: Resolva as multiplicações ou divisões primeiro!";
    } else {
      dica = switch (tipo) {
        "basica" when exp.contains('+') => lang == 'en' ? "Addition is joining quantities together!" : "Somar é o mesmo que juntar quantidades!",
        "basica" when exp.contains('-') => lang == 'en' ? "Subtraction is what's left after taking away." : "Subtração é o que sobra ao tirar uma parte.",
        "basica" when exp.contains('×') => lang == 'en' ? "Multiplication is repeated addition." : "Multiplicação é uma soma repetida.",
        "divisao"     => lang == 'en' ? "Division is splitting into equal parts." : "Dividir é repartir em partes iguais.",
        "equacao"     => lang == 'en' ? "Think of 'x' as an empty box to fill." : "Pense no 'x' como um buraco vazio a preencher.",
        "porcentagem" => lang == 'en' ? "Tip: 10% is the same as dividing by 10!" : "Dica: 10% é o mesmo que dividir por 10!",
        "fracao"      => lang == 'en' ? "Fractions are parts of a whole." : "Frações são pedaços de um todo.",
        "raiz"        => lang == 'en' ? "What number multiplied by itself gives this value?" : "Qual número multiplicado por ele mesmo dá esse valor?",
        "regra3"      => lang == 'en' ? "Find the unit value first." : "Descubra o valor unitário primeiro.",
        _             => lang == 'en' ? "Read carefully, you can do it!" : "Leia com atenção, você consegue!"
      };
    }

    return Pergunta(pergunta: questao, resposta: res, tipo: tipo, dica: dica);
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