class ActivityLog {
  final String id;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final String? userFullName;
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
    this.userFullName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'] as String? ?? '';
    final normalizedCreatedAt = rawCreatedAt.isNotEmpty &&
            !rawCreatedAt.endsWith('Z') &&
            !rawCreatedAt.contains(RegExp(r'[+-]\d{2}:\d{2}$'))
        ? '${rawCreatedAt}Z'
        : rawCreatedAt;
    final parsedCreatedAt = DateTime.tryParse(normalizedCreatedAt);

    return ActivityLog(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
      userName: json['user_name'] as String?,
      userFullName: json['user_full_name'] as String?,
      action: json['action'] as String? ?? 'unknown',
      entityType: json['entity_type'] as String? ?? 'unknown',
      entityId: json['entity_id'] as String?,
      entityName: json['entity_name'] as String?,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      createdAt: parsedCreatedAt?.toUtc().add(const Duration(hours: 3)) ??
          DateTime.now().toUtc().add(const Duration(hours: 3)),
    );
  }
}
