class WorkspaceMember {
  final String id;
  final String userId;
  final String workspaceId;
  final String role;
  final DateTime createdAt;

  WorkspaceMember({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.role,
    required this.createdAt,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workspaceId: json['workspace_id'] as String,
      role: json['role'] as String? ?? 'member',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// A wrapper model that includes user details (fetched separately)
class WorkspaceMemberDetail {
  final WorkspaceMember member;
  final String? email;
  final String? fullName;

  WorkspaceMemberDetail({required this.member, this.email, this.fullName});
}
