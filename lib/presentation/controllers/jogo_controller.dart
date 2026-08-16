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
      await _flutterTts.setVolume(1.0);
      await _flutterTts.awaitSpeakCompletion(true);
      await _speech.initialize();
      
      _flutterTts.setCompletionHandler(() {
        _estaFalandoAgora = false;
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<void> falar(String pergunta) async {
    if (pergunta.trim().isEmpty) return;
    
    // Evita loop se for a mesma pergunta exata enquanto já fala
    if (pergunta == _ultimaPerguntaFalada && _estaFalandoAgora) return;
    
    _ultimaPerguntaFalada = pergunta;
    _estaFalandoAgora = true;
    
    try {
      await _flutterTts.stop();
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 150));
        await _flutterTts.setLanguage("pt-BR");
      }

      // Remove palavras duplicadas como "quanto é" ou interrogações caso já venham na string
      String perguntaLimpa = pergunta
          .replaceAll(RegExp(r'(quanto é|quanto e|\?)', caseSensitive: false), '')
          .trim();

      String textoParaFalar = perguntaLimpa
          .replaceAll('+', ' mais ')
          .replaceAll('-', ' menos ')
          .replaceAll('x', ' vezes ')
          .replaceAll('/', ' dividido por ');

      await _flutterTts.speak("Quanto é $textoParaFalar ?");
    } catch (e) {
      _estaFalandoAgora = false;
      print("Erro no TTS: $e");
    }
  }

  /// Reseta a trava e força a fala da nova pergunta
  void prepararProximaPergunta(String novaPergunta) {
    if (_ultimaPerguntaFalada != novaPergunta) {
      _ultimaPerguntaFalada = ""; 
      falar(novaPergunta);
    } else {
      // Caso seja a mesma string por algum motivo, força a releitura limpando a trava
      _ultimaPerguntaFalada = "";
      falar(novaPergunta);
    }
  }

  Future<void> falarFeedbackSistema(String mensagem) async {
    if (mensagem.trim().isEmpty) return;
    _estaFalandoAgora = true;
    try {
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _flutterTts.speak(mensagem);
    } catch (_) {}
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