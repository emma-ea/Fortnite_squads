import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/squad.dart';

abstract class SquadRepository {
  // Fetch squads the user is already a member of (Source 34)
  Future<Either<Failure, List<Squad>>> getMySquads();

  // Find open squads in the region (Mirroring Player Discovery logic in Source 26)
  Future<Either<Failure, List<Squad>>> discoverSquads({
    required String region, 
    List<String>? gameModes,
  });

  Future<Either<Failure, Squad>> createSquad(Map<String, dynamic> squadData);

  Future<Either<Failure, Squad>> getSquadDetails(String squadId);
}