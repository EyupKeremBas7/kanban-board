class ChecklistItem {
  final String id;
  final String cardId;
  final String title;
  final bool isCompleted;
  final double position;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChecklistItem({
    required this.id,
    required this.cardId,
    required this.title,
    required this.isCompleted,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      position: (json['position'] as num?)?.toDouble() ?? 65535.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ChecklistItem copyWith({
    String? id,
    String? cardId,
    String? title,
    bool? isCompleted,
    double? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'title': title,
      'is_completed': isCompleted,
      'position': position,
    };
  }
}
