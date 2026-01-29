import 'package:equatable/equatable.dart';

class SquadMember extends Equatable {
  final String userId;
  final String username;
  final String? profilePictureUrl;
  final String role; // 'LEADER' or 'MEMBER'
  final bool isOnline;

  const SquadMember({
    required this.userId,
    required this.username,
    this.profilePictureUrl,
    required this.role,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [userId, username, role, isOnline];
}