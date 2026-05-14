"""
Activity log event handler.

Notifications are user-targeted. Activity logs are audit-style records of
workspace, board, card, comment, and checklist actions.
"""
import logging
from uuid import UUID

from sqlmodel import Session

from app.core.db import engine
from app.events.types import (
    BoardCreatedEvent,
    BoardDeletedEvent,
    BoardUpdatedEvent,
    CardAssignedEvent,
    CardCreatedEvent,
    CardDeletedEvent,
    CardMovedEvent,
    CardUpdatedEvent,
    ChecklistCreatedEvent,
    ChecklistDeletedEvent,
    ChecklistToggledEvent,
    ChecklistUpdatedEvent,
    CommentAddedEvent,
    CommentDeletedEvent,
    CommentUpdatedEvent,
    InvitationRespondedEvent,
    InvitationSentEvent,
    ListCreatedEvent,
    ListDeletedEvent,
    ListUpdatedEvent,
    WorkspaceCreatedEvent,
    WorkspaceDeletedEvent,
    WorkspaceMemberAddedEvent,
    WorkspaceMemberRemovedEvent,
    WorkspaceUpdatedEvent,
)
from app.models.activity_logs import ActionType, EntityType
from app.models.boards import Board
from app.models.cards import Card
from app.models.lists import BoardList
from app.repository import activity_logs as activity_repo

logger = logging.getLogger(__name__)

ActivityEvent = (
    BoardCreatedEvent
    | BoardUpdatedEvent
    | BoardDeletedEvent
    | CardCreatedEvent
    | CardUpdatedEvent
    | CardDeletedEvent
    | CardMovedEvent
    | CardAssignedEvent
    | ListCreatedEvent
    | ListUpdatedEvent
    | ListDeletedEvent
    | ChecklistCreatedEvent
    | ChecklistUpdatedEvent
    | ChecklistDeletedEvent
    | ChecklistToggledEvent
    | CommentAddedEvent
    | CommentUpdatedEvent
    | CommentDeletedEvent
    | InvitationSentEvent
    | InvitationRespondedEvent
    | WorkspaceCreatedEvent
    | WorkspaceUpdatedEvent
    | WorkspaceDeletedEvent
    | WorkspaceMemberAddedEvent
    | WorkspaceMemberRemovedEvent
)


def _board_context(session: Session, board_id: UUID | None) -> tuple[UUID | None, UUID | None]:
    if not board_id:
        return None, None
    board = session.get(Board, board_id)
    return board_id, board.workspace_id if board else None


def _list_context(session: Session, list_id: UUID | None) -> tuple[UUID | None, UUID | None]:
    if not list_id:
        return None, None
    board_list = session.get(BoardList, list_id)
    if not board_list:
        return None, None
    return _board_context(session, board_list.board_id)


def _card_context(session: Session, card_id: UUID | None) -> tuple[UUID | None, UUID | None]:
    if not card_id:
        return None, None
    card = session.get(Card, card_id)
    if not card:
        return None, None
    return _list_context(session, card.list_id)


def _create(
    *,
    session: Session,
    user_id: UUID,
    action: ActionType,
    entity_type: EntityType,
    entity_id: UUID,
    entity_name: str | None = None,
    board_id: UUID | None = None,
    workspace_id: UUID | None = None,
    details: dict | None = None,
) -> None:
    activity_repo.create_activity_log(
        session=session,
        user_id=user_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        entity_name=entity_name,
        board_id=board_id,
        workspace_id=workspace_id,
        details=details,
    )


def handle_activity_log(event: ActivityEvent) -> None:
    """Persist activity logs for product timeline screens."""
    with Session(engine) as session:
        try:
            if isinstance(event, BoardCreatedEvent):
                _create(
                    session=session,
                    user_id=event.created_by_id,
                    action=ActionType.created,
                    entity_type=EntityType.board,
                    entity_id=event.board_id,
                    entity_name=event.board_name,
                    board_id=event.board_id,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, BoardUpdatedEvent):
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.board,
                    entity_id=event.board_id,
                    entity_name=event.board_name,
                    board_id=event.board_id,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, BoardDeletedEvent):
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.board,
                    entity_id=event.board_id,
                    entity_name=event.board_name,
                    board_id=event.board_id,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, ListCreatedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.created_by_id,
                    action=ActionType.created,
                    entity_type=EntityType.list,
                    entity_id=event.list_id,
                    entity_name=event.list_name,
                    board_id=board_id,
                    workspace_id=workspace_id,
                )

            elif isinstance(event, ListUpdatedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.list,
                    entity_id=event.list_id,
                    entity_name=event.list_name,
                    board_id=board_id,
                    workspace_id=workspace_id,
                )

            elif isinstance(event, ListDeletedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.list,
                    entity_id=event.list_id,
                    entity_name=event.list_name,
                    board_id=board_id,
                    workspace_id=workspace_id,
                )

            elif isinstance(event, CardCreatedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.created_by_id,
                    action=ActionType.created,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"list_id": str(event.list_id)},
                )

            elif isinstance(event, CardUpdatedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"list_id": str(event.list_id)},
                )

            elif isinstance(event, CardDeletedEvent):
                board_id, workspace_id = _board_context(session, event.board_id)
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"list_id": str(event.list_id)},
                )

            elif isinstance(event, CardMovedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.moved_by_id,
                    action=ActionType.moved,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={
                        "old_list_name": event.old_list_name,
                        "new_list_name": event.new_list_name,
                    },
                )

            elif isinstance(event, CardAssignedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.assigned_by_id,
                    action=ActionType.assigned,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"assignee_id": str(event.assignee_id), "assignee_email": event.assignee_email},
                )

            elif isinstance(event, CommentAddedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.commenter_id,
                    action=ActionType.commented,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.card_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"comment_preview": event.comment_content[:160]},
                )

            elif isinstance(event, CommentUpdatedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name="Comment",
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"comment_id": str(event.comment_id)},
                )

            elif isinstance(event, CommentDeletedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name="Comment",
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"comment_id": str(event.comment_id)},
                )

            elif isinstance(event, ChecklistCreatedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.created_by_id,
                    action=ActionType.created,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.item_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"checklist_item_id": str(event.item_id), "child_type": "checklist_item"},
                )

            elif isinstance(event, ChecklistUpdatedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.item_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"checklist_item_id": str(event.item_id), "child_type": "checklist_item"},
                )

            elif isinstance(event, ChecklistDeletedEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.item_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={"checklist_item_id": str(event.item_id), "child_type": "checklist_item"},
                )

            elif isinstance(event, ChecklistToggledEvent):
                board_id, workspace_id = _card_context(session, event.card_id)
                _create(
                    session=session,
                    user_id=event.toggled_by_id,
                    action=ActionType.completed if event.is_completed else ActionType.updated,
                    entity_type=EntityType.card,
                    entity_id=event.card_id,
                    entity_name=event.item_title,
                    board_id=board_id,
                    workspace_id=workspace_id,
                    details={
                        "checklist_item_id": str(event.item_id),
                        "child_type": "checklist_item",
                        "is_completed": event.is_completed,
                    },
                )

            elif isinstance(event, InvitationSentEvent):
                _create(
                    session=session,
                    user_id=event.inviter_id,
                    action=ActionType.invited,
                    entity_type=EntityType.workspace,
                    entity_id=event.workspace_id,
                    entity_name=event.workspace_name,
                    workspace_id=event.workspace_id,
                    details={"invitee_id": str(event.invitee_id), "invitee_email": event.invitee_email},
                )

            elif isinstance(event, InvitationRespondedEvent):
                _create(
                    session=session,
                    user_id=event.responder_id,
                    action=ActionType.joined if event.accepted else ActionType.updated,
                    entity_type=EntityType.workspace,
                    entity_id=event.workspace_id,
                    entity_name=event.workspace_name,
                    workspace_id=event.workspace_id,
                    details={"accepted": event.accepted, "invitation_id": str(event.invitation_id)},
                )

            elif isinstance(event, WorkspaceCreatedEvent):
                _create(
                    session=session,
                    user_id=event.created_by_id,
                    action=ActionType.created,
                    entity_type=EntityType.workspace,
                    entity_id=event.workspace_id,
                    entity_name=event.workspace_name,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, WorkspaceUpdatedEvent):
                _create(
                    session=session,
                    user_id=event.updated_by_id,
                    action=ActionType.updated,
                    entity_type=EntityType.workspace,
                    entity_id=event.workspace_id,
                    entity_name=event.workspace_name,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, WorkspaceDeletedEvent):
                _create(
                    session=session,
                    user_id=event.deleted_by_id,
                    action=ActionType.deleted,
                    entity_type=EntityType.workspace,
                    entity_id=event.workspace_id,
                    entity_name=event.workspace_name,
                    workspace_id=event.workspace_id,
                )

            elif isinstance(event, WorkspaceMemberAddedEvent):
                _create(
                    session=session,
                    user_id=event.added_by_id,
                    action=ActionType.joined,
                    entity_type=EntityType.member,
                    entity_id=event.member_id,
                    entity_name=event.role,
                    workspace_id=event.workspace_id,
                    details={"member_user_id": str(event.member_user_id), "role": event.role},
                )

            elif isinstance(event, WorkspaceMemberRemovedEvent):
                _create(
                    session=session,
                    user_id=event.removed_by_id,
                    action=ActionType.left,
                    entity_type=EntityType.member,
                    entity_id=event.member_id,
                    workspace_id=event.workspace_id,
                    details={"member_user_id": str(event.member_user_id)},
                )

        except Exception as exc:
            logger.error("Activity log handler failed for %s: %s", type(event).__name__, exc)
