import 'package:equatable/equatable.dart';

class Squad extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int currentSize;
  final int maxSize;
  final String? avatarUrl;
  final List<String> tags;
  final bool isPublic;
  final String leaderId;

  const Squad({
    required this.id,
    required this.name,
    this.description,
    required this.currentSize,
    required this.maxSize,
    this.avatarUrl,
    required this.tags,
    required this.isPublic,
    required this.leaderId,
  });

  @override
  List<Object?> get props => [id, name, currentSize, maxSize, tags];
}