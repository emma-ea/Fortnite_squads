import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/squad.dart';
import '../../domain/repositories/squad_repository.dart';
import '../models/squad_model.dart'; // Mapped from Squad entity

@LazySingleton(as: SquadRepository)
class SquadRepositoryImpl implements SquadRepository {
  final Dio _dio;

  SquadRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<Squad>>> getMySquads() async {
    try {
      // Endpoint defined in Source 34
      final response = await _dio.get('/users/me/squads');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['squads'];
        return Right(data.map((json) => SquadModel.fromJson(json)).toList());
      }
      return Left(ServerFailure('Failed to load squads'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }

  @override
  Future<Either<Failure, List<Squad>>> discoverSquads({
    required String region,
    List<String>? gameModes,
  }) async {
    try {
      // Inferring endpoint based on standard REST practices and Source 26 (Discovery)
      final response = await _dio.get(
        '/squads/discover',
        queryParameters: {
          'region': region,
          if (gameModes != null) 'gameModes': gameModes.join(','),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['content'];
        return Right(data.map((json) => SquadModel.fromJson(json)).toList());
      }
      return Left(ServerFailure('Failed to discover squads'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }

  @override
  Future<Either<Failure, Squad>> createSquad(Map<String, dynamic> squadData) async {
    try {
      // Endpoint defined in Source 32
      final response = await _dio.post('/squads', data: squadData);
      
      if (response.statusCode == 201) {
        return Right(SquadModel.fromJson(response.data));
      }
      return Left(ServerFailure('Failed to create squad'));
    } catch (e) {
      return Left(ServerFailure('Network error'));
    }
  }

  @override
Future<Either<Failure, Squad>> getSquadDetails(String squadId) async {
  try {
    final response = await _dio.get('/squads/$squadId');
    if (response.statusCode == 200) {
      // Logic to parse Squad + Members list would go here
      // For now, we reuse SquadModel, assuming it can handle the extra data
      // or we map it to a specific SquadDetail entity if they differ significantly.
      return Right(SquadModel.fromJson(response.data)); 
    }
    return Left(ServerFailure('Failed to load details'));
  } catch (e) {
    return Left(ServerFailure('Network error'));
  }
}
}