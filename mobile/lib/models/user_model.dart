import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    avatar: json['avatar'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    preferences: json['preferences'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'avatar': avatar,
    'created_at': createdAt.toIso8601String(),
    'preferences': preferences,
  };
}
