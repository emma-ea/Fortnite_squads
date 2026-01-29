part of 'squad_bloc.dart';

class CreateSquadRequested extends SquadEvent {
  final String name;
  final String? description;
  final int maxSize;
  final String visibility; // 'PUBLIC', 'PRIVATE', 'INVITE_ONLY'
  final List<String> tags;

  CreateSquadRequested({
    required this.name,
    this.description,
    required this.maxSize,
    required this.visibility,
    required this.tags,
  });

  @override
  List<Object?> get props => [name, description, maxSize, visibility, tags];
}

class LoadSquadDetails extends SquadEvent {
  final String squadId;
  LoadSquadDetails(this.squadId);
}

class RemoveMemberRequested extends SquadEvent {
  final String squadId;
  final String userId;
  RemoveMemberRequested({required this.squadId, required this.userId});
}