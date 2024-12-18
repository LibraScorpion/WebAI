import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/chat_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/chat_widgets/message_bubble.dart';
import '../../widgets/chat_widgets/chat_input.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatProvider>().clearMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          const ChatInput(),
        ],
      ),
    );
  }
}
