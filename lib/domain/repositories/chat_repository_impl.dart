import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart'; // Mapped from Message entity

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  final _messageStreamController = StreamController<Message>.broadcast();

  ChatRepositoryImpl(this._dio);

  @override
  Stream<Message> get messageStream => _messageStreamController.stream;

  @override
  Future<Either<Failure, List<Message>>> getMessages(String squadId, {int page = 0}) async {
    try {
      // Endpoint: GET /api/v1/squads/{squadId}/messages [cite: 62]
      final response = await _dio.get(
        '/squads/$squadId/messages',
        queryParameters: {'page': page, 'size': 50},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['content'];
        return Right(data.map((json) => MessageModel.fromJson(json)).toList());
      }
      return Left(ServerFailure('Failed to load messages'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(String squadId, String text) async {
    try {
      // Endpoint: POST /api/v1/squads/{squadId}/messages [cite: 62]
      final response = await _dio.post(
        '/squads/$squadId/messages',
        data: {'text': text},
      );

      if (response.statusCode == 201) {
        final message = MessageModel.fromJson(response.data);
        // Manually add to stream so UI updates instantly without waiting for poll
        _messageStreamController.add(message); 
        return Right(message);
      }
      return Left(ServerFailure('Failed to send message'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendImageMessage(String squadId, File imageFile) async {
    try {
      // Multipart upload for images [cite: 62]
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '/squads/$squadId/messages/image',
        data: formData,
      );

      if (response.statusCode == 201) {
        final message = MessageModel.fromJson(response.data);
        _messageStreamController.add(message);
        return Right(message);
      }
      return Left(ServerFailure('Failed to upload image'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }
}