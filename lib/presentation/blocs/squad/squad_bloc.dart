import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/squad.dart';
import '../../../domain/entities/squad_member.dart';
import '../../../domain/repositories/squad_repository.dart';

part 'squad_event.dart';
part 'squad_state.dart';

// Events
abstract class SquadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMySquads extends SquadEvent {}
class DiscoverSquadsRequested extends SquadEvent {
  final String region;
  DiscoverSquadsRequested(this.region);
}

// States
abstract class SquadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SquadInitial extends SquadState {}
class SquadLoading extends SquadState {}
class SquadLoaded extends SquadState {
  final List<Squad> mySquads;
  final List<Squad> discoverableSquads;

  SquadLoaded({this.mySquads = const [], this.discoverableSquads = const []});

  @override
  List<Object?> get props => [mySquads, discoverableSquads];
  
  SquadLoaded copyWith({List<Squad>? mySquads, List<Squad>? discoverableSquads}) {
    return SquadLoaded(
      mySquads: mySquads ?? this.mySquads,
      discoverableSquads: discoverableSquads ?? this.discoverableSquads,
    );
  }
}
class SquadError extends SquadState {
  final String message;
  SquadError(this.message);
}

// BLoC
@injectable
class SquadBloc extends Bloc<SquadEvent, SquadState> {
  final SquadRepository _squadRepository;

  SquadBloc(this._squadRepository) : super(SquadInitial()) {
    on<LoadMySquads>(_onLoadMySquads);
    on<DiscoverSquadsRequested>(_onDiscoverSquads);
    on<CreateSquadRequested>(_onCreateSquadRequested);
  }

  Future<void> _onLoadMySquads(LoadMySquads event, Emitter<SquadState> emit) async {
    // Preserve existing discovery list if possible
    List<Squad> currentDiscovery = [];
    if (state is SquadLoaded) {
      currentDiscovery = (state as SquadLoaded).discoverableSquads;
    }
    
    emit(SquadLoading());
    
    final result = await _squadRepository.getMySquads();
    
    result.fold(
      (failure) => emit(SquadError(failure.message)),
      (squads) => emit(SquadLoaded(mySquads: squads, discoverableSquads: currentDiscovery)),
    );
  }

  Future<void> _onDiscoverSquads(DiscoverSquadsRequested event, Emitter<SquadState> emit) async {
    List<Squad> currentMySquads = [];
    if (state is SquadLoaded) {
      currentMySquads = (state as SquadLoaded).mySquads;
    }

    // Don't emit full loading to avoid flickering "My Squads" tab
    // In a real app, you'd use separate status flags.
    
    final result = await _squadRepository.discoverSquads(region: event.region);
    
    result.fold(
      (failure) => emit(SquadError(failure.message)),
      (squads) => emit(SquadLoaded(mySquads: currentMySquads, discoverableSquads: squads)),
    );
  }

  Future<void> _onCreateSquadRequested(
  CreateSquadRequested event,
  Emitter<SquadState> emit,
) async {
  emit(SquadLoading());

  final Map<String, dynamic> squadData = {
    'squadName': event.name,
    'description': event.description,
    'maxSize': event.maxSize,
    'visibility': event.visibility,
    'tags': event.tags,
    // 'preferredPlayTimes': ... (omitted for MVP, can be added later)
  };

  final result = await _squadRepository.createSquad(squadData);

  result.fold(
    (failure) => emit(SquadError(failure.message)),
    (squad) {
      // Emit success to trigger navigation
      emit(SquadCreatedSuccess(squad.id));
      // Immediately reload the list so "My Squads" is up to date when we return
      add(LoadMySquads()); 
    },
  );
}

Future<void> _onLoadSquadDetails(LoadSquadDetails event, Emitter<SquadState> emit) async {
  emit(SquadLoading());
  final result = await _squadRepository.getSquadDetails(event.squadId);
  
  result.fold(
    (failure) => emit(SquadError(failure.message)),
    (squad) {
      // We need the current user ID to check if they are the leader.
      // In a real app, inject UserBloc or StorageService to get 'myUserId'.
      final myUserId = 'current-user-id-placeholder'; 
      
      // Parse members from the squad object (assuming Squad entity was updated to hold them)
      // or fetch them via a separate call if your API requires it.
      final members = <SquadMember>[]; // populated from result
      
      emit(SquadDetailsLoaded(
        squad: squad,
        members: members,
        isLeader: squad.leaderId == myUserId,
      ));
    },
  );
}
}