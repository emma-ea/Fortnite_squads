import 'package:dartz/dartz.dart'; // Functional error handling
import '../../core/errors/failures.dart';
import '../models/user_model.dart';


abstract class AuthRepository {
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  });

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<Either<Failure, void>> verifyEmail(String token);
}