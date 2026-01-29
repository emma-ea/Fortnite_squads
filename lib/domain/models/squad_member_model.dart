import '../../domain/entities/squad_member.dart';

class SquadMemberModel extends SquadMember {
  const SquadMemberModel({
    required super.userId,
    required super.username,
    super.profilePictureUrl,
    required super.role,
    required super.isOnline,
  });

  factory SquadMemberModel.fromJson(Map<String, dynamic> json) {
    return SquadMemberModel(
      userId: json['userId'],
      username: json['username'],
      profilePictureUrl: json['profilePictureUrl'],
      role: json['role'], // LEADER, MEMBER
      isOnline: json['isOnline'] ?? false,
    );
  }
}