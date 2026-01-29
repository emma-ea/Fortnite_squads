import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/user_repository.dart';

// --- Events ---
abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateProfileRequested extends UserEvent {
  final String username;
  final String epicId;
  final String region;
  final String skillLevel;
  final List<String> preferredModes;
  final File? avatarFile; // Optional avatar to upload during save

  UpdateProfileRequested({
    required this.username,
    required this.epicId,
    required this.region,
    required this.skillLevel,
    required this.preferredModes,
    this.avatarFile,
  });
}

// --- States ---
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserUpdateSuccess extends UserState {
  final UserProfile profile;
  UserUpdateSuccess(this.profile);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// --- BLoC ---
@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    // 1. If an avatar was selected, upload it first (Source 15)
    if (event.avatarFile != null) {
      final uploadResult =
          await _userRepository.uploadAvatar(event.avatarFile!);

      // If upload fails, we stop and show error
      if (uploadResult.isLeft()) {
        uploadResult.fold(
          (failure) => emit(UserError(failure.message)),
          (_) => null,
        );
        return;
      }
    }

    // 2. Save the rest of the profile data (Source 13)
    final result = await _userRepository.updateProfile(
      username: event.username,
      epicId: event.epicId,
      region: event.region,
      skillLevel: event.skillLevel,
      preferredModes: event.preferredModes,
    );

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (profile) => emit(UserUpdateSuccess(profile)),
    );
  }
}
