/// Backend karşılığı: checklists.py → ChecklistItemPublic
class ChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;
  final double position;
  final String cardId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.position = 65535.0,
    required this.cardId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      position: (json['position'] as num?)?.toDouble() ?? 65535.0,
      cardId: json['card_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'position': position,
      'card_id': cardId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
}
