// FILE PATH: lib/features/avatar/models/conversation_message.dart
// Message models for conversation system

enum MessageType {
  user,
  avatar,
  system,
  error,
}

enum MessageSource {
  text,
  voice,
  suggestion,
  system,
}

class ConversationMessage {
  final String id;
  final MessageType type;
  final MessageSource source;
  final String content;
  final DateTime timestamp;
  final bool isProcessing;
  final Map<String, dynamic>? metadata;

  const ConversationMessage({
    required this.id,
    required this.type,
    required this.source,
    required this.content,
    required this.timestamp,
    this.isProcessing = false,
    this.metadata,
  });

  ConversationMessage copyWith({
    String? id,
    MessageType? type,
    MessageSource? source,
    String? content,
    DateTime? timestamp,
    bool? isProcessing,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isProcessing: isProcessing ?? this.isProcessing,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'source': source.toString(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isProcessing': isProcessing,
      'metadata': metadata,
    };
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => MessageType.user,
      ),
      source: MessageSource.values.firstWhere(
        (s) => s.toString() == json['source'],
        orElse: () => MessageSource.text,
      ),
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isProcessing: json['isProcessing'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}