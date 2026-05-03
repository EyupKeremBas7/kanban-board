class BoardCard {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final double position;
  final String? assignedTo;
  final DateTime? dueDate;
  final String? coverImage;
  final int commentCount; // MOCK for now
  final String checklistProgress; // MOCK for now

  BoardCard({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    required this.position,
    this.assignedTo,
    this.dueDate,
    this.coverImage,
    this.commentCount = 0,
    this.checklistProgress = '0/0',
  });

  factory BoardCard.fromJson(Map<String, dynamic> json) {
    return BoardCard(
      id: json['id'] as String,
      listId: json['list_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: (json['position'] as num?)?.toDouble() ?? 65535.0,
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      coverImage: json['cover_image'] as String?,
      // API currently doesn't return counts, use 0
      commentCount: 0,
      checklistProgress: '0/0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'description': description,
      'position': position,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
      'cover_image': coverImage,
    };
  }
}
