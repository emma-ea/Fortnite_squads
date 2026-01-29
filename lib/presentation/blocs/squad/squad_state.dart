part of 'squad_bloc.dart';

class SquadCreatedSuccess extends SquadState {
  final String squadId;
  SquadCreatedSuccess(this.squadId);
  
  @override
  List<Object?> get props => [squadId];
}

class SquadDetailsLoaded extends SquadState {
  final Squad squad;
  final List<SquadMember> members;
  final bool isLeader; // Helper to show/hide admin buttons

  SquadDetailsLoaded({
    required this.squad,
    required this.members,
    required this.isLeader,
  });

  @override
  List<Object?> get props => [squad, members, isLeader];
}