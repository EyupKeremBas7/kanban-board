"""
Event Types - Concrete event classes for different actions.
"""
from dataclasses import dataclass
from uuid import UUID

from app.events.base import Event


@dataclass
class CardMovedEvent(Event):
    """Fired when a card is moved to a different list."""
    card_id: UUID
    card_title: str
    old_list_name: str
    new_list_name: str
    moved_by_id: UUID
    moved_by_name: str
    # Owner = card creator, Assignee = assigned person (notifications go to assignee)
    card_owner_id: UUID | None = None
    card_owner_email: str | None = None
    card_assignee_id: UUID | None = None
    card_assignee_email: str | None = None


@dataclass
class CommentAddedEvent(Event):
    """Fired when a comment is added to a card."""
    card_id: UUID
    card_title: str
    comment_content: str
    commenter_id: UUID
    commenter_name: str
    card_owner_id: UUID | None = None
    card_owner_email: str | None = None
    card_assignee_id: UUID | None = None
    card_assignee_email: str | None = None


@dataclass
class ChecklistToggledEvent(Event):
    """Fired when a checklist item is toggled."""
    item_id: UUID
    card_id: UUID
    card_title: str
    item_title: str
    is_completed: bool
    toggled_by_id: UUID
    toggled_by_name: str
    card_owner_id: UUID | None = None
    card_owner_email: str | None = None
    card_assignee_id: UUID | None = None
    card_assignee_email: str | None = None


@dataclass
class CardAssignedEvent(Event):
    """Fired when a card is assigned to someone."""
    card_id: UUID
    card_title: str
    assigned_by_id: UUID
    assigned_by_name: str
    assignee_id: UUID
    assignee_email: str


@dataclass
class InvitationSentEvent(Event):
    """Fired when a workspace invitation is sent."""
    invitation_id: UUID
    workspace_id: UUID
    workspace_name: str
    inviter_id: UUID
    inviter_name: str
    invitee_id: UUID
    invitee_email: str


@dataclass
class InvitationRespondedEvent(Event):
    """Fired when an invitation is accepted or rejected."""
    invitation_id: UUID
    workspace_id: UUID
    workspace_name: str
    accepted: bool
    responder_id: UUID
    responder_name: str
    inviter_id: UUID


@dataclass
class WorkspaceCreatedEvent(Event):
    """Fired when a workspace is created."""
    workspace_id: UUID
    workspace_name: str
    created_by_id: UUID
    created_by_name: str


@dataclass
class WorkspaceUpdatedEvent(Event):
    """Fired when a workspace is updated."""
    workspace_id: UUID
    workspace_name: str
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class WorkspaceDeletedEvent(Event):
    """Fired when a workspace is deleted."""
    workspace_id: UUID
    workspace_name: str
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class WelcomeEmailSentEvent(Event):
    """Fired when a welcome email is sent."""
    user_id: UUID
    user_email: str


@dataclass
class CardCreatedEvent(Event):
    """Fired when a new card is created."""
    card_id: UUID
    card_title: str
    list_id: UUID
    board_id: UUID
    created_by_id: UUID
    created_by_name: str


@dataclass
class CardDeletedEvent(Event):
    """Fired when a card is deleted."""
    card_id: UUID
    card_title: str
    list_id: UUID
    board_id: UUID
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class CardUpdatedEvent(Event):
    """Fired when a card is updated (title, description, etc.)."""
    card_id: UUID
    card_title: str
    list_id: UUID
    board_id: UUID
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class ListCreatedEvent(Event):
    """Fired when a new list is created."""
    list_id: UUID
    list_name: str
    board_id: UUID
    created_by_id: UUID
    created_by_name: str


@dataclass
class ListUpdatedEvent(Event):
    """Fired when a list is updated."""
    list_id: UUID
    list_name: str
    board_id: UUID
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class ListDeletedEvent(Event):
    """Fired when a list is deleted."""
    list_id: UUID
    list_name: str
    board_id: UUID
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class BoardCreatedEvent(Event):
    """Fired when a board is created."""
    board_id: UUID
    board_name: str
    workspace_id: UUID
    created_by_id: UUID
    created_by_name: str


@dataclass
class BoardUpdatedEvent(Event):
    """Fired when a board is updated."""
    board_id: UUID
    board_name: str
    workspace_id: UUID
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class BoardDeletedEvent(Event):
    """Fired when a board is deleted."""
    board_id: UUID
    board_name: str
    workspace_id: UUID
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class ChecklistCreatedEvent(Event):
    """Fired when a checklist item is created."""
    item_id: UUID
    card_id: UUID
    item_title: str
    created_by_id: UUID
    created_by_name: str


@dataclass
class ChecklistDeletedEvent(Event):
    """Fired when a checklist item is deleted."""
    item_id: UUID
    card_id: UUID
    item_title: str
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class ChecklistUpdatedEvent(Event):
    """Fired when a checklist item is updated."""
    item_id: UUID
    card_id: UUID
    item_title: str
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class CommentDeletedEvent(Event):
    """Fired when a comment is deleted."""
    comment_id: UUID
    card_id: UUID
    deleted_by_id: UUID
    deleted_by_name: str


@dataclass
class CommentUpdatedEvent(Event):
    """Fired when a comment is updated."""
    comment_id: UUID
    card_id: UUID
    updated_by_id: UUID
    updated_by_name: str


@dataclass
class WorkspaceMemberAddedEvent(Event):
    """Fired when a member is added to a workspace."""
    workspace_id: UUID
    member_id: UUID
    member_user_id: UUID
    role: str
    added_by_id: UUID
    added_by_name: str


@dataclass
class WorkspaceMemberRemovedEvent(Event):
    """Fired when a member is removed from a workspace."""
    workspace_id: UUID
    member_id: UUID
    member_user_id: UUID
    removed_by_id: UUID
    removed_by_name: str
