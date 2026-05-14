import logging
import asyncio
from typing import Union
from app.core.sockets import SocketManager
from app.events.types import (
    CardMovedEvent,
    CommentAddedEvent,
    ChecklistToggledEvent,
    CardAssignedEvent,
    InvitationSentEvent,
    InvitationRespondedEvent,
    WorkspaceCreatedEvent,
    WorkspaceUpdatedEvent,
    WorkspaceDeletedEvent,
    CardCreatedEvent,
    CardDeletedEvent,
    CardUpdatedEvent,
    ListCreatedEvent,
    ListUpdatedEvent,
    ListDeletedEvent,
    BoardCreatedEvent,
    BoardUpdatedEvent,
    BoardDeletedEvent,
    ChecklistCreatedEvent,
    ChecklistDeletedEvent,
    ChecklistUpdatedEvent,
    CommentDeletedEvent,
    CommentUpdatedEvent,
    WorkspaceMemberAddedEvent,
    WorkspaceMemberRemovedEvent,
)

logger = logging.getLogger(__name__)

SocketNotifiableEvent = Union[
    CardMovedEvent,
    CommentAddedEvent,
    ChecklistToggledEvent,
    CardAssignedEvent,
    InvitationSentEvent,
    InvitationRespondedEvent,
    WorkspaceCreatedEvent,
    WorkspaceUpdatedEvent,
    WorkspaceDeletedEvent,
    CardCreatedEvent,
    CardDeletedEvent,
    CardUpdatedEvent,
    ListCreatedEvent,
    ListUpdatedEvent,
    ListDeletedEvent,
    BoardCreatedEvent,
    BoardUpdatedEvent,
    BoardDeletedEvent,
    ChecklistCreatedEvent,
    ChecklistDeletedEvent,
    ChecklistUpdatedEvent,
    CommentDeletedEvent,
    CommentUpdatedEvent,
    WorkspaceMemberAddedEvent,
    WorkspaceMemberRemovedEvent,
]

def handle_socket(event: SocketNotifiableEvent) -> None:
    """
    Handler that broadcasts events to connected clients via Socket.IO.
    """
    event_type = type(event).__name__
    data = {}

    # Extract basic info
    if hasattr(event, "__dict__"):
        data = {k: str(v) if isinstance(v, (type(None),)) else v for k, v in event.__dict__.items()}
        # Convert UUIDs to strings for JSON serialization
        for k, v in data.items():
            if hasattr(v, "hex"):
                data[k] = str(v)

    # We need to run the async emit from a synchronous context
    # Use the stored main loop from SocketManager
    loop = SocketManager._loop

    if loop and loop.is_running():
        asyncio.run_coroutine_threadsafe(
            SocketManager.emit(event_type, data),
            loop
        )
        logger.info(f"Socket.IO: Event {event_type} dispatched asynchronously via main loop")
    else:
        logger.warning(f"Socket.IO: No running main loop found to dispatch {event_type}")
