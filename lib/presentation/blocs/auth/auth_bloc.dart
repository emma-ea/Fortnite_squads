import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/storage_service.dart';
import '../../../domain/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  AuthBloc(this._authRepository, this._storageService) : super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      dateOfBirth: event.dateOfBirth,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(const RegistrationSuccess(
        message: 'Registration successful. Please verify your email.',
      )),
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Check if we have a token
    final token = await _storageService.getAccessToken();

    if (token != null) {
      // 2. Ideally, we would fetch the user profile here to ensure validity
      // For now, we assume authenticated if token exists, or implement
      // a generic 'User' object until profile fetch completes.
      // In a real app, you might trigger a 'FetchProfile' event here.

      // Temporary placeholder user to satisfy state until profile loads
      emit(const Authenticated(user: UserModel(id: 'cached', email: '', username: '', isEmailVerified: false)));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onVerifyEmailRequested(
      VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // Assuming verifyEmail is added to repository as per Source 8
    final result = await _authRepository.verifyEmail(event.token);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      // On success, we generally want them to log in again to get a fresh token
      (_) => emit(
          const RegistrationSuccess(message: "Email verified! Please log in.")),
    );
  }
}
