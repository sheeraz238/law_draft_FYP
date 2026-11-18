import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Bolne se text banata hai (phone ki apni awaz pehchanne ki service se)
class VoiceInput {
  static final SpeechToText _stt = SpeechToText();
  static final ValueNotifier<bool> listening = ValueNotifier<bool>(false);
  static bool _ready = false;

  static Future<bool> _init() async {
    if (_ready) return true;
    _ready = await _stt.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') listening.value = false;
      },
      onError: (_) => listening.value = false,
    );
    return _ready;
  }

  static String _code(String id) =>
      id.split(RegExp(r'[_-]')).first.toLowerCase();

  /// Masla ho to message wapas deta hai, sab theek ho to null
  static Future<String?> start({
    required String lang, // 'ur' ya 'en'
    required void Function(String text) onText,
  }) async {
    final ok = await _init();
    if (!ok) {
      return 'Awaz pehchanne ki ijazat nahi mili, ya ye device ya browser '
          'support nahi karta. Mic ki ijazat check karein '
          '(web par Chrome istemal karein).';
    }

    final locales = await _stt.locales();
    LocaleName? pick;
    for (final l in locales) {
      if (_code(l.localeId) == lang) {
        if (pick == null || l.localeId.toUpperCase().contains('PK')) pick = l;
      }
    }
    if (locales.isNotEmpty && pick == null) {
      return lang == 'ur'
          ? 'Is phone par Urdu bolne ki pehchan maujood nahi. Phone ki Google '
                'voice settings mein Urdu add karein, ya English chunein.'
          : 'English bolne ki pehchan maujood nahi.';
    }

    listening.value = true;
    await _stt.listen(
      onResult: (r) => onText(r.recognizedWords),
      localeId: pick?.localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
    );
    return null;
  }

  static Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
    listening.value = false;
  }

  static Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (_) {}
    listening.value = false;
  }
}
