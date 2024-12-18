import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }

    // Initialize speech to text
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech to text error: $error'),
      onStatus: (status) => print('Speech to text status: $status'),
    );

    return _isInitialized;
  }

  Future<bool> startListening({
    required Function(String text) onResult,
    required Function() onComplete,
  }) async {
    if (!_isInitialized && !await initialize()) {
      return false;
    }

    return await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          onComplete();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }

  bool get isListening => _speechToText.isListening;

  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  void dispose() {
    _speechToText.cancel();
  }
}
