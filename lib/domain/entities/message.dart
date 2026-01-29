import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? text;
  final String? imageUrl;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    this.text,
    this.imageUrl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, text, imageUrl, timestamp];
}