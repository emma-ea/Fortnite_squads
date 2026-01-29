part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  
  const Authenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

// Specific state to handle the "Check Email" redirect after sign up
class RegistrationSuccess extends AuthState {
  final String message;
  
  const RegistrationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}