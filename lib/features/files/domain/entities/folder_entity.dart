import 'package:equatable/equatable.dart';

class FolderEntity extends Equatable {
  const FolderEntity({
    required this.id,
    this.userId,
    required this.name,
    this.color,
    this.icon,
    required this.createdAt,
  });

  final String id;
  final String? userId;
  final String name;
  final String? color;
  final String? icon;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name];
}
