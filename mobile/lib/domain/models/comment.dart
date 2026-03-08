/// Backend karşılığı: comments.py → CardCommentPublic / CardCommentWithUser
class CardComment {
  final String id;
  final String content;
  final String cardId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  // Zenginleştirilmiş alanlar
  final String? userFullName;
  final String? userEmail;

  const CardComment({
    required this.id,
    required this.content,
    required this.cardId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.userFullName,
    this.userEmail,
  });

  factory CardComment.fromJson(Map<String, dynamic> json) {
    return CardComment(
      id: json['id'] as String,
      content: json['content'] as String,
      cardId: json['card_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      userFullName: json['user_full_name'] as String?,
      userEmail: json['user_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'card_id': cardId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }
}
