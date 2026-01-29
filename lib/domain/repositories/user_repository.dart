import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  
  Future<Either<Failure, UserProfile>> updateProfile({
    required String username,
    required String epicId,
    required String region,
    required String skillLevel,
    required List<String> preferredModes,
    String? aboutMe,
  });

  Future<Either<Failure, String>> uploadAvatar(File imageFile);
}