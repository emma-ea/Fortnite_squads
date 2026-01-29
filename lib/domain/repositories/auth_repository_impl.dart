import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart'; // Your configured Dio
import '../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final StorageService _storageService;

  AuthRepositoryImpl(this._dio, this._storageService);

  @override
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    try {
      // Endpoint defined in SRS Source 7
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0], // YYYY-MM-DD
      });

      // Based on SRS Source 8, successful registration returns 201 Created
      if (response.statusCode == 201) {
        // We don't get a token immediately on register (email verification required),
        // but we get user data.
        return Right(UserModel.fromJson(response.data)); 
      }
      return Left(ServerFailure('Registration failed: ${response.statusMessage}'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Network Error'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Endpoint defined in SRS Source 9
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Persist tokens immediately (Source 10)
        await _storageService.saveAccessToken(data['accessToken']);
        await _storageService.saveRefreshToken(data['refreshToken']);
        
        return Right(UserModel.fromJson(data['user']));
      }
      return Left(ServerFailure('Login failed'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Login Failed'));
    }
  }

  @override
  Future<void> logout() async {
    // Attempt to notify server (Source 10), then clear local tokens regardless of result
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storageService.clearTokens();
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      // Endpoint defined in SRS Source 8
      final response = await _dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        // SRS Source 8: Returns { "message": "...", "verified": true }
        // We consider 200 OK as success.
        return const Right(null);
      }
      return Left(ServerFailure('Verification failed'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Verification failed'));
    }
  }
  
}