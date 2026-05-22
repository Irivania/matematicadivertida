// lib/presentation/controllers/jogo_controller.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class JogoController extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _ultimaPerguntaFalada = "";
  bool _estaOuvindoMicrofone = false;
  bool _estaFalandoAgora = false;

  bool get estaOuvindoMicrofone => _estaOuvindoMicrofone;

  JogoController() {
    _initMotoresVoz();
  }

  Future<void> _initMotoresVoz() async {
    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.55);
      await _speech.initialize();
      
      _flutterTts.setCompletionHandler(() {
        _estaFalandoAgora = false;
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<void> falar(String pergunta) async {
    if (pergunta.trim().isEmpty) return;
    // Se for a mesma pergunta exata e o motor já estiver processando, aborta a duplicação
    if (pergunta == _ultimaPerguntaFalada && _estaFalandoAgora) return;
    
    _ultimaPerguntaFalada = pergunta;
    _estaFalandoAgora = true;
    
    await _flutterTts.stop();

    String textoParaFalar = pergunta
        .replaceAll('+', ' mais ')
        .replaceAll('-', ' menos ')
        .replaceAll('x', ' vezes ')
        .replaceAll('/', ' dividido por ');

    await _flutterTts.speak("Quanto é $textoParaFalar ?");
  }

  /// Comunica por voz se o jogador errou ou esgotou o tempo
  Future<void> falarFeedbackSistema(String mensagem) async {
    _estaFalandoAgora = true;
    await _flutterTts.stop();
    await _flutterTts.speak(mensagem);
  }

  Future<void> alternarMicrofone({
    required Function(String) onTextoCapturado,
    required VoidCallback onFinalizado,
  }) async {
    if (_estaFalandoAgora) return;

    if (!_estaOuvindoMicrofone) {
      bool disponivel = await _speech.initialize();
      if (disponivel) {
        _estaOuvindoMicrofone = true;
        notifyListeners();

        _speech.listen(
          onResult: (val) {
            if (_estaFalandoAgora) return;
            onTextoCapturado(val.recognizedWords);
            if (val.finalResult) {
              _estaOuvindoMicrofone = false;
              notifyListeners();
              onFinalizado();
            }
          },
          localeId: "pt_BR",
        );
      }
    } else {
      pararMicrofone();
    }
  }

  void pararMicrofone() {
    _estaOuvindoMicrofone = false;
    _speech.stop();
    notifyListeners();
  }

  void pararTTS() {
    _estaFalandoAgora = false;
    _flutterTts.stop();
  }

  void resetarTrava() {
    _ultimaPerguntaFalada = "";
    _estaFalandoAgora = false;
  }
}