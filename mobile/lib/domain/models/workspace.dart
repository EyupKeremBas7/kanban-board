/// Backend karşılığı: workspaces.py → WorkspacePublic
class Workspace {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final bool isArchived;
  final bool isDeleted;

  const Workspace({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    this.isArchived = false,
    this.isDeleted = false,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }
}
