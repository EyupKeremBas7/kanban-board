/// Backend karşılığı: lists.py → ListPublic (tablo: board_list)
class BoardList {
  final String id;
  final String name;
  final double position;
  final String boardId;
  final bool isArchived;
  final bool isDeleted;

  const BoardList({
    required this.id,
    required this.name,
    this.position = 65535.0,
    required this.boardId,
    this.isArchived = false,
    this.isDeleted = false,
  });

  factory BoardList.fromJson(Map<String, dynamic> json) {
    return BoardList(
      id: json['id'] as String,
      name: json['name'] as String,
      position: (json['position'] as num?)?.toDouble() ?? 65535.0,
      boardId: json['board_id'] as String,
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'board_id': boardId,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }
}
