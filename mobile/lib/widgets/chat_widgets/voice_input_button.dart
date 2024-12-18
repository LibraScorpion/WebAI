import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onVoiceInput;

  const VoiceInputButton({
    super.key,
    required this.onVoiceInput,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        _showError('Error: $error');
      },
    );
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showError('Microphone permission denied');
      return;
    }

    if (!_speech.isAvailable) {
      _showError('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          widget.onVoiceInput(result.recognizedWords);
          setState(() {
            _isListening = false;
          });
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      onPressed: _isListening ? _stopListening : _startListening,
      color: _isListening
          ? Theme.of(context).colorScheme.primary
          : null,
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
