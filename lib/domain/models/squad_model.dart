import '../../domain/entities/squad.dart';

class SquadModel extends Squad {
  const SquadModel({
    required super.id,
    required super.name,
    super.description,
    required super.currentSize,
    required super.maxSize,
    super.avatarUrl,
    required super.tags,
    required super.isPublic,
    required super.leaderId,
  });

  factory SquadModel.fromJson(Map<String, dynamic> json) {
    return SquadModel(
      // SRS Source 34: JSON keys match the API response
      id: json['squadId'] ?? '',
      name: json['squadName'] ?? 'Unknown Squad',
      description: json['description'],
      
      // SRS Source 36: DB defaults are 1 and 4 respectively
      currentSize: json['currentSize'] ?? 1,
      maxSize: json['maxSize'] ?? 4,
      
      avatarUrl: json['avatarUrl'],
      
      // Handle potential nulls for list
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? 
          [],
          
      // SRS Source 34: Visibility is an ENUM string ('PUBLIC', 'PRIVATE', etc.)
      // We map this to the simpler boolean used by the Entity
      isPublic: json['visibility'] == 'PUBLIC',
      
      leaderId: json['squadLeaderId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'squadId': id,
      'squadName': name,
      'description': description,
      'currentSize': currentSize,
      'maxSize': maxSize,
      'avatarUrl': avatarUrl,
      'tags': tags,
      'visibility': isPublic ? 'PUBLIC' : 'INVITE_ONLY',
      'squadLeaderId': leaderId,
    };
  }
}