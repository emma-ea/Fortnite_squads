import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// General failure for API errors (500s, 404s, Network issues)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Failure for local storage issues (e.g., getting JWT from secure storage)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Specific failure for authentication (e.g., "Invalid Password")
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}