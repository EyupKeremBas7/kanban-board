from __future__ import annotations

import uuid
from datetime import datetime
from enum import Enum
from typing import TYPE_CHECKING

from sqlalchemy import UniqueConstraint
from sqlmodel import Field, SQLModel

if TYPE_CHECKING:
    pass


class NotificationType(str, Enum):
    """Types of notifications"""
    workspace_invitation = "workspace_invitation"
    invitation_accepted = "invitation_accepted"
    invitation_rejected = "invitation_rejected"
    comment_added = "comment_added"
    card_assigned = "card_assigned"
    card_due_soon = "card_due_soon"
    mentioned = "mentioned"
    card_moved = "card_moved"
    checklist_toggled = "checklist_toggled"


class NotificationBase(SQLModel):
    type: NotificationType
    title: str = Field(max_length=255)
    message: str = Field(max_length=1000)
    is_read: bool = Field(default=False)
    # Reference IDs for navigation
    reference_id: uuid.UUID | None = None  # e.g., invitation_id, card_id
    reference_type: str | None = None  # e.g., "invitation", "card", "comment"


class NotificationCreate(SQLModel):
    user_id: uuid.UUID
    type: NotificationType
    title: str
    message: str
    reference_id: uuid.UUID | None = None
    reference_type: str | None = None


class Notification(NotificationBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="user.id", ondelete="CASCADE", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class NotificationPublic(NotificationBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime


class NotificationsPublic(SQLModel):
    data: list[NotificationPublic]
    count: int
    unread_count: int


class NotificationPreferenceBase(SQLModel):
    in_app_enabled: bool = True
    email_enabled: bool = True
    comments_enabled: bool = True
    assignments_enabled: bool = True
    card_moves_enabled: bool = True
    checklist_enabled: bool = True
    invitations_enabled: bool = True
    mentions_enabled: bool = True


class NotificationPreference(NotificationPreferenceBase, table=True):
    __tablename__ = "notification_preference"
    __table_args__ = (UniqueConstraint("user_id", name="uq_notification_preference_user"),)

    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="user.id", ondelete="CASCADE", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class NotificationPreferencePublic(NotificationPreferenceBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime


class NotificationPreferenceUpdate(SQLModel):
    in_app_enabled: bool | None = None
    email_enabled: bool | None = None
    comments_enabled: bool | None = None
    assignments_enabled: bool | None = None
    card_moves_enabled: bool | None = None
    checklist_enabled: bool | None = None
    invitations_enabled: bool | None = None
    mentions_enabled: bool | None = None
