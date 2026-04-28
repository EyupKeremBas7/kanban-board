class ActivityLog {
  final String id;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final String action;
  final String entityType;
  final String? entityId;
  final String? entityName;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    this.userId,
    this.userEmail,
    this.userName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
      userName: json['user_name'] as String?,
      action: json['action'] as String? ?? 'unknown',
      entityType: json['entity_type'] as String? ?? 'unknown',
      entityId: json['entity_id'] as String?,
      entityName: json['entity_name'] as String?,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
