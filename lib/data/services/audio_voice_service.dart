import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AudioVoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _isListening = false;
  String _wordsSpoken = "";
  bool _speechEnabled = false;

  bool get isListening => _isListening;
  String get wordsSpoken => _wordsSpoken;
  bool get speechEnabled => _speechEnabled;

  AudioVoiceService() {
    _initVoiceServices();
  }

  Future<void> _initVoiceServices() async {
    try {
      await _tts.setLanguage("pt-BR");
      await _tts.setSpeechRate(0.5); 
      await _tts.setPitch(1.1);      
      await _tts.setVolume(1.0);     
      await _tts.awaitSpeakCompletion(true);

      _speechEnabled = await _stt.initialize(
        onError: (val) => print('Erro no STT: ${val.errorMsg}'),
        onStatus: (val) => print('Status do STT: $val'),
      );
    } catch (e) {
      print('Erro ao inicializar serviços de voz: $e');
      _speechEnabled = false;
    }
    notifyListeners();
  }

  /// Interrompe a fala anterior e inicia a leitura da nova pergunta de forma segura para o navegador
  Future<void> falarProximaPergunta(String pergunta) async {
    if (pergunta.isNotEmpty) {
      try {
        await _tts.stop(); 
        
        // Pequeno respiro para limpar o buffer de áudio do navegador e evitar falhas de SpeechSynthesis
        await Future.delayed(const Duration(milliseconds: 150));

        if (kIsWeb) {
          await _tts.setLanguage("pt-BR");
        }

        var resultado = await _tts.speak(pergunta);
        if (resultado == 1) {
          print("Nova pergunta reproduzida com sucesso.");
        } else {
          print("Falha ao reproduzir nova pergunta.");
        }
      } catch (e) {
        print("Erro capturado no TTS do navegador: $e");
      }
    }
  }

  Future<void> falarPergunta(String pergunta) async {
    await falarProximaPergunta(pergunta);
  }

  Future<void> pararFala() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

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
      listenMode: ListenMode.confirmation,
      onResult: (result) {
        _wordsSpoken = result.recognizedWords;
        
        if (result.finalResult) {
          _isListening = false;
          notifyListeners();
          
          int? numeroConvertido = converterRespostaVoz(_wordsSpoken);
          onNumeroRecebido(numeroConvertido);
        }
      },
    );
  }

  Future<void> pararEscuta() async {
    await _stt.stop();
    _isListening = false;
    notifyListeners();
  }

  int? converterRespostaVoz(String textoVoz) {
    String textoLimpo = textoVoz.trim().toLowerCase();
    if (textoLimpo.isEmpty) return null;

    int? numeroDireto = int.tryParse(textoLimpo);
    if (numeroDireto != null) return numeroDireto;

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