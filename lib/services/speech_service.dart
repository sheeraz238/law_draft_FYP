import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final FlutterTts _tts = FlutterTts();
  static final ValueNotifier<bool> speaking = ValueNotifier<bool>(false);
  static bool _ready = false;

  static void _init() {
    if (_ready) return;
    _ready = true;
    _tts.setCompletionHandler(() => speaking.value = false);
    _tts.setCancelHandler(() => speaking.value = false);
    _tts.setErrorHandler((_) => speaking.value = false);
  }

  /// Masla ho to message wapas deta hai, sab theek ho to null
  static Future<String?> speak(String text, {String lang = 'en-US'}) async {
    _init();
    try {
      if (!kIsWeb) {
        final ok = await _tts.isLanguageAvailable(lang);
        if (ok != true) {
          return 'Is phone par $lang ki awaz maujood nahi. Phone ki Settings mein '
              '"Text-to-speech" se wo awaz download karein.';
        }
      }
      await _tts.setLanguage(lang);
      await _tts.setSpeechRate(0.45);
      speaking.value = true;
      await _tts.speak(text);
      return null;
    } catch (_) {
      speaking.value = false;
      return 'Awaz nahi chal saki.';
    }
  }

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    speaking.value = false;
  }
}
