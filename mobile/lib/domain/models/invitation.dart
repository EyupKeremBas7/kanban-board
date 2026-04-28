import 'package:mobile/utils/enums.dart';

/// Backend karşılığı: invitations.py → InvitationPublic
class Invitation {
  final String id;
  final String workspaceId;
  final String workspaceName;
  final String inviterId;
  final String inviterName;
  final String? inviteeId;
  final String inviteeEmail;
  final MemberRole role;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const Invitation({
    required this.id,
    required this.workspaceId,
    required this.workspaceName,
    required this.inviterId,
    required this.inviterName,
    this.inviteeId,
    required this.inviteeEmail,
    required this.role,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      workspaceName: json['workspace_name'] as String? ?? '',
      inviterId: json['inviter_id'] as String,
      inviterName: json['inviter_name'] as String? ?? 'Bilinmiyor',
      inviteeId: json['invitee_id'] as String?,
      inviteeEmail: json['invitee_email'] as String,
      role: MemberRole.values.firstWhere(
        (e) => e.name == (json['role'] as String? ?? 'member'),
        orElse: () => MemberRole.member,
      ),
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'workspace_name': workspaceName,
      'inviter_id': inviterId,
      'inviter_name': inviterName,
      'invitee_id': inviteeId,
      'invitee_email': inviteeEmail,
      'role': role.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
    };
  }
}
