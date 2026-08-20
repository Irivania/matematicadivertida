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

  /// Método universal para falar a pergunta considerando o idioma ativo (Português ou Inglês)
  Future<void> falar(String pergunta, {bool eIngles = false}) async {
    if (pergunta.trim().isEmpty) return;
    
    if (pergunta == _ultimaPerguntaFalada && _estaFalandoAgora) return;
    
    _ultimaPerguntaFalada = pergunta;
    _estaFalandoAgora = true;
    
    try {
      await _flutterTts.stop();
      
      // Define o idioma correto do TTS
      final codigoIdioma = eIngles ? "en-US" : "pt-BR";
      await _flutterTts.setLanguage(codigoIdioma);

      // Limpa termos em português ou inglês caso já venham na string
      String perguntaLimpa = pergunta
          .replaceAll(RegExp(r'(quanto é|quanto e|what is|whats is|\?)', caseSensitive: false), '')
          .trim();

      // Substitui os operadores matemáticos para a leitura correta em voz alta
      String textoParaFalar = perguntaLimpa
          .replaceAll('+', eIngles ? ' plus ' : ' mais ')
          .replaceAll('-', eIngles ? ' minus ' : ' menos ')
          .replaceAll('x', eIngles ? ' times ' : ' vezes ')
          .replaceAll('/', eIngles ? ' divided by ' : ' dividido por ');

      // Monta a frase de acordo com o idioma ativo
      String fraseFinal = eIngles 
          ? "What is $textoParaFalar ?" 
          : "Quanto é $textoParaFalar ?";

      await _flutterTts.speak(fraseFinal);
    } catch (e) {
      _estaFalandoAgora = false;
      print("Erro no TTS: $e");
    }
  }

  /// Reseta a trava e força a fala da nova pergunta repassando o idioma
  void prepararProximaPergunta(String novaPergunta, {bool eIngles = false}) {
    if (_ultimaPerguntaFalada != novaPergunta) {
      _ultimaPerguntaFalada = ""; 
      falar(novaPergunta, eIngles: eIngles);
    } else {
      _ultimaPerguntaFalada = "";
      falar(novaPergunta, eIngles: eIngles);
    }
  }

  Future<void> falarFeedbackSistema(String mensagem, {bool eIngles = false}) async {
    if (mensagem.trim().isEmpty) return;
    _estaFalandoAgora = true;
    try {
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _flutterTts.setLanguage(eIngles ? "en-US" : "pt-BR");
      await _flutterTts.speak(mensagem);
    } catch (_) {}
  }

  Future<void> alternarMicrofone({
    required Function(String) onTextoCapturado,
    required VoidCallback onFinalizado,
    bool eIngles = false,
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
          localeId: eIngles ? "en_US" : "pt_BR", // Suporta reconhecimento em inglês ou português
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