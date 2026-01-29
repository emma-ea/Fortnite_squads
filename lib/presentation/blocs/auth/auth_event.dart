part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final DateTime dateOfBirth;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.dateOfBirth,
  });

  @override
  List<Object?> get props => [email, password, dateOfBirth];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

// Triggered when the app starts to check if a user is already logged in
class AuthCheckRequested extends AuthEvent {}

class VerifyEmailRequested extends AuthEvent {
  final String token;
  const VerifyEmailRequested(this.token);
  
  @override
  List<Object?> get props => [token];
}