"""
Notifications Repository - All database operations for Notification model.
"""
import uuid
from datetime import datetime

from sqlmodel import Session, func, select

from app.models.notifications import (
    Notification,
    NotificationPreference,
    NotificationPreferenceUpdate,
    NotificationType,
)


_NOTIFICATION_CATEGORY_FIELDS = {
    NotificationType.comment_added: "comments_enabled",
    NotificationType.card_assigned: "assignments_enabled",
    NotificationType.card_moved: "card_moves_enabled",
    NotificationType.checklist_toggled: "checklist_enabled",
    NotificationType.workspace_invitation: "invitations_enabled",
    NotificationType.invitation_accepted: "invitations_enabled",
    NotificationType.invitation_rejected: "invitations_enabled",
    NotificationType.mentioned: "mentions_enabled",
}


def get_or_create_preferences(*, session: Session, user_id: uuid.UUID) -> NotificationPreference:
    """Get notification preferences, creating the default row on first use."""
    preferences = session.exec(
        select(NotificationPreference).where(NotificationPreference.user_id == user_id)
    ).first()

    if preferences:
        return preferences

    preferences = NotificationPreference(user_id=user_id)
    session.add(preferences)
    session.commit()
    session.refresh(preferences)
    return preferences


def update_preferences(
    *,
    session: Session,
    user_id: uuid.UUID,
    preferences_in: NotificationPreferenceUpdate,
) -> NotificationPreference:
    """Update current user's notification preferences."""
    preferences = get_or_create_preferences(session=session, user_id=user_id)
    update_data = preferences_in.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(preferences, field, value)

    preferences.updated_at = datetime.utcnow()
    session.add(preferences)
    session.commit()
    session.refresh(preferences)
    return preferences


def _category_enabled(
    preferences: NotificationPreference,
    notification_type: NotificationType,
) -> bool:
    field_name = _NOTIFICATION_CATEGORY_FIELDS.get(notification_type)
    if field_name is None:
        return True
    return bool(getattr(preferences, field_name))


def should_create_notification(
    *,
    session: Session,
    user_id: uuid.UUID,
    notification_type: NotificationType,
) -> bool:
    """Return whether an in-app notification should be persisted."""
    preferences = get_or_create_preferences(session=session, user_id=user_id)
    return preferences.in_app_enabled and _category_enabled(preferences, notification_type)


def should_send_email(
    *,
    session: Session,
    user_id: uuid.UUID,
    notification_type: NotificationType,
) -> bool:
    """Return whether an email notification should be queued."""
    preferences = get_or_create_preferences(session=session, user_id=user_id)
    return preferences.email_enabled and _category_enabled(preferences, notification_type)


def get_notification_by_id(*, session: Session, notification_id: uuid.UUID) -> Notification | None:
    """Get notification by ID."""
    return session.get(Notification, notification_id)


def get_user_notifications(
    *, session: Session, user_id: uuid.UUID, skip: int = 0, limit: int = 50, unread_only: bool = False
) -> tuple[list[Notification], int, int]:
    """Get notifications for a user with count and unread count."""
    # Base query
    base_query = select(Notification).where(Notification.user_id == user_id)

    if unread_only:
        base_query = base_query.where(Notification.is_read == False)

    # Get total count
    count = session.exec(
        select(func.count()).select_from(Notification).where(Notification.user_id == user_id)
    ).one()

    # Get unread count
    unread_count = session.exec(
        select(func.count()).select_from(Notification).where(
            Notification.user_id == user_id,
            Notification.is_read == False
        )
    ).one()

    # Get notifications ordered by newest first
    notifications = session.exec(
        base_query.order_by(Notification.created_at.desc()).offset(skip).limit(limit)
    ).all()

    return list(notifications), count, unread_count


def get_unread_count(*, session: Session, user_id: uuid.UUID) -> int:
    """Get count of unread notifications for a user."""
    count = session.exec(
        select(func.count()).select_from(Notification).where(
            Notification.user_id == user_id,
            Notification.is_read == False
        )
    ).one()
    return count


def get_unread_notifications(*, session: Session, user_id: uuid.UUID) -> list[Notification]:
    """Get all unread notifications for a user."""
    notifications = session.exec(
        select(Notification).where(
            Notification.user_id == user_id,
            Notification.is_read == False
        )
    ).all()
    return list(notifications)


def create_notification(
    *, session: Session,
    user_id: uuid.UUID,
    notification_type: NotificationType,
    title: str,
    message: str,
    reference_id: uuid.UUID | None = None,
    reference_type: str | None = None,
) -> Notification | None:
    """Create a new notification."""
    if not should_create_notification(
        session=session,
        user_id=user_id,
        notification_type=notification_type,
    ):
        return None

    notification = Notification(
        user_id=user_id,
        type=notification_type,
        title=title,
        message=message,
        reference_id=reference_id,
        reference_type=reference_type,
    )
    session.add(notification)
    session.commit()
    session.refresh(notification)
    return notification


def mark_as_read(*, session: Session, notification: Notification) -> Notification:
    """Mark a notification as read."""
    notification.is_read = True
    session.add(notification)
    session.commit()
    session.refresh(notification)
    return notification


def mark_all_as_read(*, session: Session, user_id: uuid.UUID) -> int:
    """Mark all notifications as read for a user. Returns count of marked notifications."""
    notifications = get_unread_notifications(session=session, user_id=user_id)

    for notification in notifications:
        notification.is_read = True
        session.add(notification)

    session.commit()
    return len(notifications)


def delete_notification(*, session: Session, notification: Notification) -> None:
    """Delete a notification."""
    session.delete(notification)
    session.commit()
