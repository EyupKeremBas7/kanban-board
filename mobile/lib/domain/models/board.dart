import 'package:mobile/utils/enums.dart';

/// Backend karşılığı: boards.py → BoardPublic
class Board {
  final String id;
  final String name;
  final Visibility visibility;
  final String? backgroundImage;
  final String workspaceId;
  final String ownerId;
  final bool isArchived;
  final bool isDeleted;

  const Board({
    required this.id,
    required this.name,
    this.visibility = Visibility.workspace,
    this.backgroundImage,
    required this.workspaceId,
    required this.ownerId,
    this.isArchived = false,
    this.isDeleted = false,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as String,
      name: json['name'] as String,
      visibility: Visibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => Visibility.workspace,
      ),
      backgroundImage: json['background_image'] as String?,
      workspaceId: json['workspace_id'] as String,
      ownerId: json['owner_id'] as String,
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visibility': visibility.name,
      'background_image': backgroundImage,
      'workspace_id': workspaceId,
      'owner_id': ownerId,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }
}
