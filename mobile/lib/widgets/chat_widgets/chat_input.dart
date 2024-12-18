import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/chat_provider.dart';
import 'voice_input_button.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _isComposing = false;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    
    context.read<ChatProvider>().sendMessage(text);
  }

  Future<void> _handleImagePicker() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        // TODO: Handle image processing and sending
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _handleVoiceInput(String text) {
    if (text.isNotEmpty) {
      _controller.text = text;
      setState(() {
        _isComposing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _handleImagePicker,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration: const InputDecoration(
                  hintText: 'Send a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            VoiceInputButton(
              onVoiceInput: _handleVoiceInput,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing
                  ? () => _handleSubmitted(_controller.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
