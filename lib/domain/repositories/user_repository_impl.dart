import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart'; // Assuming UserModel extends UserProfile

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final Dio _dio;

  UserRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String username,
    required String epicId,
    required String region,
    required String skillLevel,
    required List<String> preferredModes,
    String? aboutMe,
  }) async {
    try {
      // Endpoint defined in Source 13
      final response = await _dio.post('/users/profile', data: {
        'username': username,
        'epicGamesId': epicId,
        'region': region,
        'skillLevel': skillLevel,
        'preferredModes': preferredModes,
        'aboutMe': aboutMe,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(UserModel.fromJson(response.data));
      }
      return Left(ServerFailure('Failed to update profile'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Update Failed'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      // Multipart request as per Source 15
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '/users/profile/avatar',
        data: formData,
      );

      if (response.statusCode == 200) {
        return Right(response.data['profilePictureUrl']);
      }
      return Left(ServerFailure('Avatar upload failed'));
    } catch (e) {
      return Left(ServerFailure('Network error during upload'));
    }
  }
  
  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    // Implementation for GET /users/me (Source 14) would go here
    throw UnimplementedError(); 
  }
}