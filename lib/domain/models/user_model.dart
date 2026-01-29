import '../../domain/entities/user_profile.dart';

class UserModel extends UserProfile {
  final String email;
  final bool isEmailVerified;

  const UserModel({
    required super.id,
    required super.username,
    required this.email,
    required this.isEmailVerified,
    // Provide defaults so the model is valid even if we only have Auth data
    super.epicIds = '',
    super.region = '',
    super.skillLevel = '',
    super.preferredModes = const [],
    super.avatarUrl,
    super.aboutMe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Handles both 'userId' (Source 10) and 'user_id' (if DB raw)
      id: json['userId'] ?? json['user_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      
      // Profile Data (Source 14) - May be null during Login
      epicIds: json['epicGamesId'] ?? '',
      region: json['region'] ?? '',
      skillLevel: json['skillLevel'] ?? '',
      preferredModes: (json['preferredModes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      avatarUrl: json['profilePictureUrl'],
      aboutMe: json['aboutMe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'username': username,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'epicGamesId': epicIds,
      'region': region,
      'skillLevel': skillLevel,
      'preferredModes': preferredModes,
      'profilePictureUrl': avatarUrl,
      'aboutMe': aboutMe,
    };
  }
  
  // Create a copy of the model with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    bool? isEmailVerified,
    String? epicIds,
    String? region,
    String? skillLevel,
    List<String>? preferredModes,
    String? avatarUrl,
    String? aboutMe,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      epicIds: epicIds ?? this.epicIds,
      region: region ?? this.region,
      skillLevel: skillLevel ?? this.skillLevel,
      preferredModes: preferredModes ?? this.preferredModes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }
}