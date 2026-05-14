"""
Event Base Classes - Observer Pattern Implementation.

This module provides the foundation for event-driven architecture:
- Event: Base class for all events
- EventDispatcher: Singleton that manages event handlers and dispatching
"""
import logging
from collections.abc import Callable
from typing import TypeVar

logger = logging.getLogger(__name__)

T = TypeVar('T', bound='Event')


class Event:
    """Base class for all events (not a dataclass to avoid inheritance issues)."""
    pass


class EventDispatcher:
    """
    Singleton event dispatcher that manages event handlers.
    
    Usage:
        # Register a handler
        EventDispatcher.register(CardMovedEvent, handle_card_moved)
        
        # Dispatch an event
        EventDispatcher.dispatch(CardMovedEvent(...))
    """
    _handlers: dict[type[Event], list[Callable[[Event], None]]] = {}
    _initialized: bool = False

    @classmethod
    def register(cls, event_type: type[T], handler: Callable[[T], None]) -> None:
        """Register a handler for an event type."""
        if event_type not in cls._handlers:
            cls._handlers[event_type] = []
        cls._handlers[event_type].append(handler)
        logger.debug(f"Registered handler {handler.__name__} for {event_type.__name__}")

    @classmethod
    def dispatch(cls, event: Event) -> None:
        """Dispatch an event to all registered handlers."""
        event_type = type(event)
        handlers = cls._handlers.get(event_type, [])

        logger.info(f"Dispatching {event_type.__name__} to {len(handlers)} handlers")

        for handler in handlers:
            try:
                handler(event)
            except Exception as e:
                logger.error(f"Error in handler {handler.__name__}: {e}")

    @classmethod
    def clear(cls) -> None:
        """Clear all handlers (useful for testing)."""
        cls._handlers = {}
        cls._initialized = False

    @classmethod
    def initialize(cls) -> None:
        """Initialize event handlers. Called once at app startup."""
        if cls._initialized:
            return

        from app.events.handlers import (
            handle_email,
            handle_notification,
        )
        from app.events.activity_handler import handle_activity_log
        from app.events.socket_handler import handle_socket
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
            WorkspaceCreatedEvent,
            WorkspaceDeletedEvent,
            ListCreatedEvent,
            ListDeletedEvent,
            ListUpdatedEvent,
            WorkspaceUpdatedEvent,
            WelcomeEmailSentEvent,
            WorkspaceMemberAddedEvent,
            WorkspaceMemberRemovedEvent,
        )

        cls.register(CardMovedEvent, handle_notification)
        cls.register(CardAssignedEvent, handle_notification)
        cls.register(CommentAddedEvent, handle_notification)
        cls.register(ChecklistToggledEvent, handle_notification)
        cls.register(InvitationSentEvent, handle_notification)
        cls.register(InvitationRespondedEvent, handle_notification)

        cls.register(CardMovedEvent, handle_email)
        cls.register(CardAssignedEvent, handle_email)
        cls.register(CommentAddedEvent, handle_email)
        cls.register(ChecklistToggledEvent, handle_email)
        cls.register(WelcomeEmailSentEvent, handle_email)

        # Activity Log Handlers
        cls.register(CardMovedEvent, handle_activity_log)
        cls.register(CardAssignedEvent, handle_activity_log)
        cls.register(CardCreatedEvent, handle_activity_log)
        cls.register(CardDeletedEvent, handle_activity_log)
        cls.register(CardUpdatedEvent, handle_activity_log)
        cls.register(CommentAddedEvent, handle_activity_log)
        cls.register(CommentDeletedEvent, handle_activity_log)
        cls.register(CommentUpdatedEvent, handle_activity_log)
        cls.register(ChecklistCreatedEvent, handle_activity_log)
        cls.register(ChecklistDeletedEvent, handle_activity_log)
        cls.register(ChecklistToggledEvent, handle_activity_log)
        cls.register(ChecklistUpdatedEvent, handle_activity_log)
        cls.register(InvitationSentEvent, handle_activity_log)
        cls.register(InvitationRespondedEvent, handle_activity_log)
        cls.register(WorkspaceCreatedEvent, handle_activity_log)
        cls.register(WorkspaceDeletedEvent, handle_activity_log)
        cls.register(WorkspaceUpdatedEvent, handle_activity_log)
        cls.register(WorkspaceMemberAddedEvent, handle_activity_log)
        cls.register(WorkspaceMemberRemovedEvent, handle_activity_log)
        cls.register(ListCreatedEvent, handle_activity_log)
        cls.register(ListDeletedEvent, handle_activity_log)
        cls.register(ListUpdatedEvent, handle_activity_log)
        cls.register(BoardCreatedEvent, handle_activity_log)
        cls.register(BoardDeletedEvent, handle_activity_log)
        cls.register(BoardUpdatedEvent, handle_activity_log)

        # Socket.IO Handlers
        cls.register(CardMovedEvent, handle_socket)
        cls.register(CardAssignedEvent, handle_socket)
        cls.register(CardCreatedEvent, handle_socket)
        cls.register(CardDeletedEvent, handle_socket)
        cls.register(CardUpdatedEvent, handle_socket)
        cls.register(CommentAddedEvent, handle_socket)
        cls.register(CommentDeletedEvent, handle_socket)
        cls.register(CommentUpdatedEvent, handle_socket)
        cls.register(ChecklistCreatedEvent, handle_socket)
        cls.register(ChecklistDeletedEvent, handle_socket)
        cls.register(ChecklistToggledEvent, handle_socket)
        cls.register(ChecklistUpdatedEvent, handle_socket)
        cls.register(InvitationSentEvent, handle_socket)
        cls.register(InvitationRespondedEvent, handle_socket)
        cls.register(WorkspaceCreatedEvent, handle_socket)
        cls.register(WorkspaceDeletedEvent, handle_socket)
        cls.register(WorkspaceUpdatedEvent, handle_socket)
        cls.register(ListCreatedEvent, handle_socket)
        cls.register(ListDeletedEvent, handle_socket)
        cls.register(ListUpdatedEvent, handle_socket)
        cls.register(BoardCreatedEvent, handle_socket)
        cls.register(BoardDeletedEvent, handle_socket)
        cls.register(BoardUpdatedEvent, handle_socket)
        cls.register(WorkspaceMemberAddedEvent, handle_socket)
        cls.register(WorkspaceMemberRemovedEvent, handle_socket)

        cls._initialized = True
        logger.info("EventDispatcher initialized with handlers")
