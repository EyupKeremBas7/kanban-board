/// Backend karşılığı: cards.py → CardPublic
class KanbanCard {
  final String id;
  final String title;
  final String? description;
  final double position;
  final String listId;
  final String? createdBy;
  final String? assignedTo;
  final DateTime? dueDate;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isDeleted;
  // Zenginleştirilmiş alanlar (API response)
  final String? ownerFullName;
  final String? ownerEmail;
  final String? assigneeFullName;
  final String? assigneeEmail;

  const KanbanCard({
    required this.id,
    required this.title,
    this.description,
    this.position = 65535.0,
    required this.listId,
    this.createdBy,
    this.assignedTo,
    this.dueDate,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.isDeleted = false,
    this.ownerFullName,
    this.ownerEmail,
    this.assigneeFullName,
    this.assigneeEmail,
  });

  factory KanbanCard.fromJson(Map<String, dynamic> json) {
    return KanbanCard(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num?)?.toDouble() ?? 65535.0,
      listId: json['list_id'] as String,
      createdBy: json['created_by'] as String?,
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      coverImage: json['cover_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      ownerFullName: json['owner_full_name'] as String?,
      ownerEmail: json['owner_email'] as String?,
      assigneeFullName: json['assignee_full_name'] as String?,
      assigneeEmail: json['assignee_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'position': position,
      'list_id': listId,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }
}
