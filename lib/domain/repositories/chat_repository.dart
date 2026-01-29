import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  // Fetch initial history (Source 61, FR-6.8)
  Future<Either<Failure, List<Message>>> getMessages(String squadId, {int page = 0});

  // Send a text message (Source 61, FR-6.4)
  Future<Either<Failure, Message>> sendMessage(String squadId, String text);

  // Upload and send an image (Source 61, FR-6.5)
  Future<Either<Failure, Message>> sendImageMessage(String squadId, File imageFile);

  // Stream for real-time updates (via WebSocket or periodic polling)
  Stream<Message> get messageStream;
}