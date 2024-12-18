import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class GeneratedImage {
  final String id;
  final String url;
  final String prompt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  GeneratedImage({
    required this.id,
    required this.url,
    required this.prompt,
    required this.createdAt,
    this.metadata,
  });

  factory GeneratedImage.fromJson(Map<String, dynamic> json) => GeneratedImage(
    id: json['id'] as String,
    url: json['url'] as String,
    prompt: json['prompt'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'prompt': prompt,
    'created_at': createdAt.toIso8601String(),
    'metadata': metadata,
  };
}
