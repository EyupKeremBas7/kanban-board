class CardComment {
  final String id;
  final String cardId;
  final String userId;
  final String content;
  final String? userFullName;
  final String? userEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardComment({
    required this.id,
    required this.cardId,
    required this.userId,
    required this.content,
    this.userFullName,
    this.userEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CardComment.fromJson(Map<String, dynamic> json) {
    return CardComment(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      userFullName: json['user_full_name'] as String?,
      userEmail: json['user_email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'card_id': cardId, 'user_id': userId, 'content': content};
  }
}
