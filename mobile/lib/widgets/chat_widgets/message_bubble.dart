import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;
    final theme = Theme.of(context);

    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAI 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: _buildMessageContent(context),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.markdown:
        return MarkdownBody(
          data: message.content,
          selectable: true,
        );
      case MessageType.code:
        return SelectableText(
          message.content,
          style: const TextStyle(
            fontFamily: 'monospace',
          ),
        );
      default:
        return SelectableText(message.content);
    }
  }
}
