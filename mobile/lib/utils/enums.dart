// Backend enum karşılıkları (backend/app/models/enums.py + notifications.py + activity_logs.py)

enum Visibility { private, workspace, public }

enum MemberRole { admin, member, observer }

enum NotificationType {
  workspaceInvitation,
  invitationAccepted,
  invitationRejected,
  commentAdded,
  cardAssigned,
  cardDueSoon,
  mentioned,
  cardMoved,
  checklistToggled,
}
