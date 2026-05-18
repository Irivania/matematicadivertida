import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioVoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isListening = false;
  String _wordsSpoken = "";
  bool _speechEnabled = false;

  // Getters para expor o estado para a UI de forma segura
  bool get isListening => _isListening;
  String get wordsSpoken => _wordsSpoken;
  bool get speechEnabled => _speechEnabled;

  AudioVoiceService() {
    _initVoiceServices();
  }

  /// Inicializa as configurações de TTS (Voz) e STT (Microfone)
  Future<void> _initVoiceServices() async {
    try {
      // Configurações do Texto para Voz (TTS)
      await _tts.setLanguage("pt-BR");
      await _tts.setSpeechRate(0.5); // Velocidade natural e confortável para crianças
      await _tts.setPitch(1.1);      // Tom de voz levemente mais agudo/amigável

      // Inicializa o Reconhecimento de Voz (STT)
      _speechEnabled = await _stt.initialize(
        onError: (val) => print('Erro no STT: ${val.errorMsg}'), // <-- Corrigido para .errorMsg
        onStatus: (val) => print('Status do STT: $val'),
      );
    } catch (e) {
      print('Erro ao inicializar serviços de voz: $e');
      _speechEnabled = false;
    }
    notifyListeners();
  }

  // ==========================================
  // OUVIR: TEXT-TO-SPEECH (Falar a Pergunta)
  // ==========================================
  
  /// Transforma o texto da pergunta em áudio falado
  Future<void> falarPergunta(String pergunta) async {
    if (pergunta.isNotEmpty) {
      await _tts.stop(); // Interrompe qualquer fala anterior antes de começar uma nova
      await _tts.speak(pergunta);
    }
  }

  /// Interrompe a fala do jogo imediatamente (ex: quando muda de tela)
  Future<void> pararFala() async {
    await _tts.stop();
  }

  // ==========================================
  // RESPONDER: SPEECH-TO-TEXT (Ouvir o Usuário)
  // ==========================================

  /// Inicia a captura do microfone e devolve o número convertido no callback
  Future<void> iniciarEscuta(Function(int? numero) onNumeroRecebido) async {
    if (!_speechEnabled) {
      print("O reconhecimento de voz não está disponível ou não foi autorizado.");
      return;
    }

    _isListening = true;
    _wordsSpoken = "";
    notifyListeners();

    await _stt.listen(
      localeId: "pt_BR",
      listenMode: ListenMode.confirmation, // Otimizado para respostas curtas/comandos
      onResult: (result) {
        _wordsSpoken = result.recognizedWords;
        
        // Se o algoritmo finalizou o processamento da frase/número
        if (result.finalResult) {
          _isListening = false;
          notifyListeners();
          
          // Converte o texto bruto recebido em um número inteiro válido
          int? numeroConvertido = converterRespostaVoz(_wordsSpoken);
          
          // Devolve o número (ou null) para quem chamou o método
          onNumeroRecebido(numeroConvertido);
        }
      },
    );
  }

  /// Força a interrupção manual da escuta do microfone
  Future<void> pararEscuta() async {
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  // ==========================================
  // PARSER: Validador Inteligente de Texto -> Número
  // ==========================================

  /// Analisa a string capturada pelo microfone e tenta transformá-la em número inteiro.
  /// Suporta retornos numéricos diretos (ex: "12") e por extenso (ex: "doze").
  int? converterRespostaVoz(String textoVoz) {
    // Limpa espaços extras e padroniza em caixa baixa
    String textoLimpo = textoVoz.trim().toLowerCase();

    if (textoLimpo.isEmpty) return null;

    // 1. Tenta a conversão direta (Caso o Google/Apple retorne o algarismo "15")
    int? numeroDireto = int.tryParse(textoLimpo);
    if (numeroDireto != null) return numeroDireto;

    // 2. Dicionário de suporte para números por extenso comuns em contas infantis
    const mapaNumeros = {
      'zero': 0, 'um': 1, 'dois': 2, 'três': 3, 'tres': 3, 'quatro': 4,
      'cinco': 5, 'seis': 6, 'sete': 7, 'oito': 8, 'nove': 9, 'dez': 10,
      'onze': 11, 'doze': 12, 'treze': 13, 'quatorze': 14, 'catorze': 14,
      'quinze': 15, 'dezesseis': 16, 'dezessete': 17, 'dezoito': 18, 
      'dezenove': 19, 'vinte': 20, 'trinta': 30, 'quarenta': 40, 'cinquenta': 50
    };

    return mapaNumeros[textoLimpo];
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }
}