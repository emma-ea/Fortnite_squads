import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderAvatarUrl,
    super.text,
    super.imageUrl,
    required super.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // SRS Source 62: The API returns a nested 'sender' object
    final sender = json['sender'] as Map<String, dynamic>?;

    return MessageModel(
      id: json['messageId'] ?? '',
      // Extract flattened fields from the nested sender object
      senderId: sender?['userId'] ?? '',
      senderName: sender?['username'] ?? 'Unknown',
      senderAvatarUrl: sender?['profilePictureUrl'],
      
      text: json['text'],
      imageUrl: json['imageUrl'],
      // SRS Source 61: Timestamp is standard ISO 8601
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': id,
      'sender': {
        'userId': senderId,
        'username': senderName,
        'profilePictureUrl': senderAvatarUrl,
      },
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}