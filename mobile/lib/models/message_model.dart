import 'package:json_annotation/json_annotation.dart';

enum MessageType {
  text,
  image,
  code,
  markdown,
  system
}

@JsonSerializable()
class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String senderId;
  final bool isAI;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.senderId,
    required this.isAI,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    content: json['content'] as String,
    type: MessageType.values.firstWhere(
      (e) => e.toString() == 'MessageType.${json['type']}',
    ),
    timestamp: DateTime.parse(json['timestamp'] as String),
    senderId: json['sender_id'] as String,
    isAI: json['is_ai'] as bool,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'sender_id': senderId,
    'is_ai': isAI,
    'metadata': metadata,
  };
}
