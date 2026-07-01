import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

class VoiceSearchService {
  VoiceSearchService._();
  static final VoiceSearchService instance = VoiceSearchService._();

  final _speech = SpeechToText();
  bool _initialized = false;

  Future<bool> ensureReady() async {
    if (_initialized) return _speech.isAvailable;
    _initialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _initialized && _speech.isAvailable;
  }

  Future<String?> listen({
    Duration listenFor = const Duration(seconds: 8),
  }) async {
    if (!await ensureReady()) return null;

    final completer = Completer<String?>();
    var heard = '';

    await _speech.listen(
      onResult: (result) {
        heard = result.recognizedWords.trim();
        if (result.finalResult && heard.isNotEmpty && !completer.isCompleted) {
          completer.complete(heard);
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: listenFor,
        pauseFor: const Duration(seconds: 2),
        cancelOnError: true,
        partialResults: true,
      ),
    );

    final result = await Future.any<String?>([
      completer.future,
      Future<String?>.delayed(listenFor, () => heard.isNotEmpty ? heard : null),
    ]);

    await _speech.stop();
    return result?.trim().isNotEmpty == true ? result!.trim() : null;
  }

  Future<void> stop() => _speech.stop();

  bool get isListening => _speech.isListening;
}
