import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String epicIds;
  final String region;
  final String skillLevel; // BEGINNER, INTERMEDIATE, ADVANCED, EXPERT
  final List<String> preferredModes; // BATTLE_ROYALE, ZERO_BUILD, etc.
  final String? avatarUrl;
  final String? aboutMe;

  const UserProfile({
    required this.id,
    required this.username,
    required this.epicIds,
    required this.region,
    required this.skillLevel,
    required this.preferredModes,
    this.avatarUrl,
    this.aboutMe,
  });

  @override
  List<Object?> get props => [id, username, epicIds, region, skillLevel, preferredModes, avatarUrl];
}