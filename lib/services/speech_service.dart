import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:chpsmamacare_main01/utils/danger_signs.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Initialize speech recognition
  Future<bool> initialize() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
      },
      onError: (errorNotification) {
        debugPrint('Speech recognition error: ${errorNotification.errorMsg}');
      },
    );
    return available;
  }

  // Start listening for speech
  void startListening({
    required Function(String) onResult,
    required Function() onListeningComplete,
    required String localeId,
  }) async {
    if (!_isListening) {
      final available = await initialize();
      if (available) {
        _isListening = true;
        await _speech.listen(
          onResult: (result) {
            final recognizedWords = result.recognizedWords;
            onResult(recognizedWords);

            // Check if any danger signs are mentioned
            if (result.finalResult) {
              _isListening = false;
              onListeningComplete();
            }
          },
          localeId: localeId,
        );
      }
    }
  }

  // Stop listening
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  // Check if the spoken text contains any danger signs
  List<String> detectDangerSigns(String spokenText) {
    final lowerCaseText = spokenText.toLowerCase();
    return DangerSigns.maternalDangerSigns
        .where((sign) => lowerCaseText.contains(sign.toLowerCase()))
        .toList();
  }

  bool get isListening => _isListening;
}
