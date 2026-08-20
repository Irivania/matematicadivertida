// lib/data/services/audio_voice_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioVoiceService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  /// Interrompe a fala anterior e inicia a leitura da nova pergunta adaptada ao idioma ("en-US" ou "pt-BR")
  Future<void> falarProximaPergunta(String pergunta, {String idioma = "pt-BR"}) async {
    if (pergunta.isNotEmpty) {
      try {
        await _tts.stop(); 
        
        // Pequeno respiro para limpar o buffer de áudio
        await Future.delayed(const Duration(milliseconds: 150));

        // Define o idioma dinamicamente (seja Web ou Mobile)
        await _tts.setLanguage(idioma);

        var resultado = await _tts.speak(pergunta);
        if (resultado == 1) {
          print("Nova pergunta reproduzida com sucesso no idioma: $idioma.");
        } else {
          print("Falha ao reproduzir nova pergunta.");
        }
      } catch (e) {
        print("Erro capturado no TTS: $e");
      }
    }
  }

  Future<void> falarPergunta(String pergunta, {String idioma = "pt-BR"}) async {
    await falarProximaPergunta(pergunta, idioma: idioma);
  }

  Future<void> pararFala() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Método para reproduzir os efeitos sonoros da pasta assets/sons/
  Future<void> tocarEfeitoSonoro(String nomeArquivo) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sons/$nomeArquivo'));
    } catch (e) {
      print("Erro ao reproduzir efeito sonoro $nomeArquivo: $e");
    }
  }

  Future<void> iniciarEscuta(Function(int? numero) onNumeroRecebido, {String localeId = "pt_BR"}) async {
    if (!_speechEnabled) {
      print("O reconhecimento de voz não está disponível ou não foi autorizado.");
      return;
    }

    _isListening = true;
    _wordsSpoken = "";
    notifyListeners();

    await _stt.listen(
      localeId: localeId, // Suporta alternar entre "pt_BR" e "en_US"
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

    // Mapa expandido para suportar números em Português e Inglês
    const mapaNumeros = {
      // Português
      'zero': 0, 'um': 1, 'dois': 2, 'três': 3, 'tres': 3, 'quatro': 4,
      'cinco': 5, 'seis': 6, 'sete': 7, 'oito': 8, 'nove': 9, 'dez': 10,
      'onze': 11, 'doze': 12, 'treze': 13, 'quatorze': 14, 'catorze': 14,
      'quinze': 15, 'dezesseis': 16, 'dezessete': 17, 'dezoito': 18, 
      'dezenove': 19, 'vinte': 20, 'trinta': 30, 'quarenta': 40, 'cinquenta': 50,
      // Inglês
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
      'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14,
      'fifteen': 15, 'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 
      'nineteen': 19, 'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50
    };

    return mapaNumeros[textoLimpo];
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}